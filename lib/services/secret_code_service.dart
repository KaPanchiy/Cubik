import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecretCodeService {
  static const String _hashPrefKey = 'secret_access_code_hash';
  static const String defaultCode = '1234';
  static const String _salt = 'cubik_pap_salt_sec_2026';

  /// Gera hash SHA-256 seguro com sal
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin.trim() + _salt);
    return sha256.convert(bytes).toString();
  }

  /// Indica se o utilizador já definiu o seu próprio código pessoal
  static Future<bool> hasCustomCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_hashPrefKey);
  }

  /// Guarda apenas o hash criptográfico do novo PIN escolhido pelo utilizador (mínimo 6 caracteres)
  static Future<bool> setSecretCode(String newCode) async {
    final trimmed = newCode.trim();
    if (trimmed.length < 6) return false;
    final prefs = await SharedPreferences.getInstance();
    final hash = hashPin(trimmed);
    return await prefs.setString(_hashPrefKey, hash);
  }

  /// Valida se o código introduzido coincide com o hash guardado (ou com '1234' para primeira configuração)
  static Future<bool> validateCode(String inputCode) async {
    final trimmed = inputCode.trim();
    final hasCustom = await hasCustomCode();
    final prefs = await SharedPreferences.getInstance();

    if (hasCustom) {
      final storedHash = prefs.getString(_hashPrefKey);
      return hashPin(trimmed) == storedHash;
    } else {
      // Se ainda não personalizou o PIN, aceita o código padrão para poder configurar
      return trimmed == defaultCode;
    }
  }
}
