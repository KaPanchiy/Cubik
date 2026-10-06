import 'package:shared_preferences/shared_preferences.dart';

class SecretCodeService {
  static const String _prefKey = 'secret_access_code';
  static const String defaultCode = '1234';

  /// Obtém a senha secreta atual (retorna '1234' por defeito se não foi definida)
  static Future<String> getSecretCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) ?? defaultCode;
  }

  /// Guarda uma nova senha secreta definida pelo utilizador
  static Future<bool> setSecretCode(String newCode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_prefKey, newCode.trim());
  }

  /// Valida se o código introduzido coincide com a senha secreta
  static Future<bool> validateCode(String inputCode) async {
    final currentCode = await getSecretCode();
    return inputCode.trim().toLowerCase() == currentCode.trim().toLowerCase();
  }
}
