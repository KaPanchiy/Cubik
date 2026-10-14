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
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      category: json['category'] as String? ?? 'Geral',
      severity: json['severity'] as String? ?? 'Médio',
      description: json['description'] as String? ?? '',
    );
  }

  String encode() => jsonEncode(toJson());

  factory IncidentEntry.decode(String str) =>
      IncidentEntry.fromJson(jsonDecode(str) as Map<String, dynamic>);
}
