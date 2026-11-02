import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:cubik/main.dart';
import 'package:cubik/modelos/board.dart';
import 'package:cubik/services/boost_service.dart';
import 'package:cubik/services/game_codes.dart';
import 'package:cubik/services/encryption_service.dart';
import 'package:cubik/services/secret_code_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cubik app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });

  group('Board Unit Tests', () {
    test('Tabuleiro inicia 8x8 vazio e pontuação 0', () {
      final board = Board();
      expect(board.grid.length, Board.rows);
      expect(board.grid[0].length, Board.columns);
      expect(board.score, 0);
    });

    test('Reset do tabuleiro limpa a pontuação', () {
      final board = Board();
      board.score = 500;
      board.reset();
      expect(board.score, 0);
    });
  });

  group('Boost Service Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Código de boost BLOCK2026 é reconhecido case-insensitive', () {
      expect(BoostService.isBoostCode('BLOCK2026'), isTrue);
      expect(BoostService.isBoostCode('block2026'), isTrue);
      expect(BoostService.isBoostCode('Block2026'), isTrue);
      expect(BoostService.isBoostCode('INVALIDO'), isFalse);
    });

    test('Limite diário de 3 usos do boost é respeitado', () async {
      final use1 = await BoostService.activateBoost();
      expect(use1, 2); // 2 restantes

      final use2 = await BoostService.activateBoost();
      expect(use2, 1); // 1 restante

      final use3 = await BoostService.activateBoost();
      expect(use3, 0); // 0 restantes

      final use4 = await BoostService.activateBoost();
      expect(use4, -1); // Limite atingido!
    });
  });

  group('AES-256 Encryption Tests', () {
    final keyA = enc.Key.fromSecureRandom(32);
    final keyB = enc.Key.fromSecureRandom(32);

    test('Cifra e decifra texto com AES-256 corretamente', () {
      const originalText = 'Relato confidencial de incidente';
      final encrypted = EncryptionService.encryptWithKey(originalText, keyA);

      expect(encrypted, startsWith('ENC_AES256:'));
      expect(encrypted, isNot(originalText));
      expect(EncryptionService.isEncrypted(encrypted), isTrue);

      final decrypted = EncryptionService.decryptWithKey(encrypted, keyA);
      expect(decrypted, originalText);
    });

    test('Chave errada não devolve o texto original e trata o erro em segurança', () {
      const sensitiveData = 'Informação crítica de segurança';
      final encrypted = EncryptionService.encryptWithKey(sensitiveData, keyA);

      final decrypted = EncryptionService.decryptWithKey(encrypted, keyB);
      expect(decrypted, isNot(sensitiveData));
      expect(decrypted, contains('Erro ao decifrar'));
    });
  });

  group('PIN Hashing & Security Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Hash SHA-256 é determinístico e não expõe texto limpo', () {
      final hash1 = SecretCodeService.hashPin('123456');
      final hash2 = SecretCodeService.hashPin('123456');
      final hashOther = SecretCodeService.hashPin('654321');

      expect(hash1.length, 64);
      expect(hash1, hash2);
      expect(hash1, isNot(hashOther));
      expect(hash1, isNot(contains('123456')));
    });

    test('Definição de PIN próprio com mínimo 6 caracteres e validação', () async {
      expect(await SecretCodeService.hasCustomCode(), isFalse);

      // Rejeita PIN menor que 6 caracteres
      final tooShort = await SecretCodeService.setSecretCode('123');
      expect(tooShort, isFalse);

      // Aceita PIN com 6 ou mais caracteres
      final valid = await SecretCodeService.setSecretCode('987654');
      expect(valid, isTrue);
      expect(await SecretCodeService.hasCustomCode(), isTrue);

      // Valida com o novo código
      expect(await SecretCodeService.validateCode('987654'), isTrue);
      // Código antigo 1234 já não funciona
      expect(await SecretCodeService.validateCode('1234'), isFalse);
    });
  });

  group('Game Codes Constants', () {
    test('Códigos de jogo coincidem com constantes esperadas', () {
      expect(GameCodes.boostCode, 'BLOCK2026');
      expect(GameCodes.reviveCode, 'REVIVE');
    });
  });
}
