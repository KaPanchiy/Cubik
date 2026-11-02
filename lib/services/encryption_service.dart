import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço de Cifra AES-256 para proteção do Diário.
/// - Utiliza chave criptográfica de 256 bits guardada de forma segura no Keystore / Keychain (via FlutterSecureStorage).
/// - A chave é independente do PIN do utilizador: mudar o PIN NUNCA quebra nem perde os registos do diário.
/// - Cada cifra gera um IV (Vector de Inicialização) criptograficamente aleatório de 16 bytes.
class EncryptionService {
  static const String _prefix = 'ENC_AES256:';
  static const String _storageKey = 'cubik_diary_aes_key';

  static const _storage = FlutterSecureStorage();

  static enc.Key? _cachedKey;

  /// Obtém a chave AES-256 existente do Keystore ou gera uma nova de 256 bits
  static Future<enc.Key> getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;

    String? keyBase64;
    try {
      keyBase64 = await _storage.read(key: _storageKey);
    } catch (_) {}

    if (keyBase64 == null || keyBase64.isEmpty) {
      final newKey = enc.Key.fromSecureRandom(32);
      try {
        await _storage.write(key: _storageKey, value: newKey.base64);
      } catch (_) {}
      _cachedKey = newKey;
      return newKey;
    }

    _cachedKey = enc.Key.fromBase64(keyBase64);
    return _cachedKey!;
  }

  /// Cifra texto utilizando AES-256 e IV seguro aleatório
  static Future<String> encrypt(String plainText) async {
    if (plainText.isEmpty) return plainText;
    final key = await getOrCreateKey();
    return encryptWithKey(plainText, key);
  }

  /// Cifra texto com uma chave específica (utilizado também para testes unitários)
  static String encryptWithKey(String plainText, enc.Key key) {
    if (plainText.isEmpty) return plainText;
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Formato: prefixo + base64(IV + CipherText)
    final combinedBytes = Uint8List(iv.bytes.length + encrypted.bytes.length);
    combinedBytes.setRange(0, iv.bytes.length, iv.bytes);
    combinedBytes.setRange(iv.bytes.length, combinedBytes.length, encrypted.bytes);

    return '$_prefix${base64.encode(combinedBytes)}';
  }

  /// Decifra o texto cifrado utilizando a chave AES-256 do dispositivo
  static Future<String> decrypt(String cipherText) async {
    if (!isEncrypted(cipherText)) return cipherText;
    final key = await getOrCreateKey();
    return decryptWithKey(cipherText, key);
  }

  /// Decifra texto com uma chave específica (utilizado também para testes unitários)
  static String decryptWithKey(String cipherText, enc.Key key) {
    if (!isEncrypted(cipherText)) return cipherText;

    try {
      final base64Payload = cipherText.substring(_prefix.length);
      final rawBytes = base64.decode(base64Payload);
      if (rawBytes.length < 16) return '[Registo corrompido]';

      final iv = enc.IV(rawBytes.sublist(0, 16));
      final encryptedData = enc.Encrypted(rawBytes.sublist(16));

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(encryptedData, iv: iv);
    } catch (_) {
      return '[Erro ao decifrar: Chave inacessível ou registo corrompido]';
    }
  }

  /// Verifica se a string está cifrada com AES-256
  static bool isEncrypted(String text) => text.startsWith(_prefix);
}
