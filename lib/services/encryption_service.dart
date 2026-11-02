import 'dart:convert';

/// Serviço de cifra local para proteção de dados sensíveis do diário.
/// Garante que antes de ir para o Firestore ou armazenamento local, o texto esteja cifrado com o PIN do utilizador.
class EncryptionService {
  static const String _prefix = 'ENC:';

  /// Cifra o texto com a chave (PIN) fornecida e retorna texto codificado em Base64
  static String encrypt(String plainText, String key) {
    if (plainText.isEmpty || key.isEmpty) return plainText;
    final textBytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(key);
    final result = List<int>.filled(textBytes.length, 0);

    for (int i = 0; i < textBytes.length; i++) {
      result[i] = textBytes[i] ^ keyBytes[i % keyBytes.length];
    }

    return '$_prefix${base64.encode(result)}';
  }

  /// Decifra o texto cifrado com a chave (PIN) fornecida
  static String decrypt(String cipherText, String key) {
    if (!cipherText.startsWith(_prefix) || key.isEmpty) return cipherText;
    try {
      final base64Str = cipherText.substring(_prefix.length);
      final cipherBytes = base64.decode(base64Str);
      final keyBytes = utf8.encode(key);
      final result = List<int>.filled(cipherBytes.length, 0);

      for (int i = 0; i < cipherBytes.length; i++) {
        result[i] = cipherBytes[i] ^ keyBytes[i % keyBytes.length];
      }

      return utf8.decode(result);
    } catch (_) {
      return '[Erro ao decifrar: PIN incorreto]';
    }
  }

  /// Indica se uma string já está cifrada
  static bool isEncrypted(String text) => text.startsWith(_prefix);
}
