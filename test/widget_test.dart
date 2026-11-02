import 'package:flutter_test/flutter_test.dart';
import 'package:cubik/main.dart';
import 'package:cubik/modelos/board.dart';
import 'package:cubik/services/boost_service.dart';

void main() {
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
    test('Código de boost BLOCK2026 é reconhecido case-insensitive', () {
      expect(BoostService.isBoostCode('BLOCK2026'), isTrue);
      expect(BoostService.isBoostCode('block2026'), isTrue);
      expect(BoostService.isBoostCode('Block2026'), isTrue);
      expect(BoostService.isBoostCode('INVALIDO'), isFalse);
    });
  });
}
