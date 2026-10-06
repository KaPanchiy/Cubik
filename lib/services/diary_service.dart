import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/incident_model.dart';

class DiaryService {
  static const String _storageKey = 'secret_diary_incidents_list';

  /// Obtém todos os incidentes registados (ordenados da data mais recente para a mais antiga)
  static Future<List<IncidentEntry>> getIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(rawJson);
      final List<IncidentEntry> list =
          jsonList.map((item) => IncidentEntry.fromJson(item)).toList();
      list.sort((a, b) => b.date.compareTo(a.date)); // Mais recentes primeiro
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Adiciona um novo incidente e guarda no dispositivo
  static Future<bool> addIncident(IncidentEntry entry) async {
    final list = await getIncidents();
    list.add(entry);
    return await _saveList(list);
  }

  /// Apaga um incidente específico pelo seu ID
  static Future<bool> deleteIncident(String id) async {
    final list = await getIncidents();
    list.removeWhere((item) => item.id == id);
    return await _saveList(list);
  }

  /// Apaga todos os registos do diário (útil para limpeza de emergência)
  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_storageKey);
  }

  static Future<bool> _saveList(List<IncidentEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        list.map((item) => item.toJson()).toList();
    return await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
