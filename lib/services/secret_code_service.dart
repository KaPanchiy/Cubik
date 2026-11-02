import 'package:shared_preferences/shared_preferences.dart';

class SecretCodeService {
  static const String _prefKey = 'secret_access_code';
  static const String defaultCode = '1234';

  /// Obtém a senha secreta atual (retorna '1234' por defeito se ainda não foi personalizada)
  static Future<String> getSecretCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) ?? defaultCode;
  }

  /// Indica se o utilizador já definiu um código próprio personalizado
  static Future<bool> hasCustomCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_prefKey);
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
