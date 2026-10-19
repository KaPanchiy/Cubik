import 'package:shared_preferences/shared_preferences.dart';

/// Gere o boost de pontuação 2x do código BLOCK2026.
/// - Máximo de 3 usos por dia (reset à meia-noite)
/// - Duração: 2 minutos por ativação
class BoostService {
  static const String _dateKey  = 'boost_promo_date';
  static const String _countKey = 'boost_promo_count';
  static const int maxUsesPerDay = 3;

  /// Verifica se o código introduzido é o código de boost (case-insensitive)
  static bool isBoostCode(String code) =>
      code.trim().toLowerCase() == 'block2026';

  /// Devolve quantas vezes o boost foi usado hoje
  static Future<int> getUsesToday() async {
    final prefs  = await SharedPreferences.getInstance();
    final today  = _todayStr();
    final saved  = prefs.getString(_dateKey) ?? '';
    if (saved != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_countKey, 0);
      return 0;
    }
    return prefs.getInt(_countKey) ?? 0;
  }

  /// Tenta ativar o boost. Retorna os usos restantes ou -1 se o limite foi atingido.
  static Future<int> activateBoost() async {
    final uses = await getUsesToday();
    if (uses >= maxUsesPerDay) return -1; // limite atingido

    final prefs    = await SharedPreferences.getInstance();
    final newCount = uses + 1;
    await prefs.setString(_dateKey, _todayStr());
    await prefs.setInt(_countKey, newCount);
    return maxUsesPerDay - newCount; // usos restantes
  }

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
