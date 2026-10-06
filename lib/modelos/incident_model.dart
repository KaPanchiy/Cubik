import 'dart:convert';

class IncidentEntry {
  final String id;
  final String title;
  final DateTime date;
  final String category;
  final String severity; // 'Baixo', 'Médio', 'Elevado'
  final String description;

  IncidentEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.severity,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'category': category,
      'severity': severity,
      'description': description,
    };
  }

  factory IncidentEntry.fromJson(Map<String, dynamic> json) {
    return IncidentEntry(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      category: json['category'] ?? 'Geral',
      severity: json['severity'] ?? 'Médio',
      description: json['description'] ?? '',
    );
  }

  String encode() => jsonEncode(toJson());

  factory IncidentEntry.decode(String str) =>
      IncidentEntry.fromJson(jsonDecode(str));
}
