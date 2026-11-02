import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentEntry {
  final String id;
  final String title;
  final DateTime date;
  final String category;
  final String severity; // 'Baixa', 'Média', 'Alta'
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  IncidentEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.severity,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  IncidentEntry copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? category,
    String? severity,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncidentEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'category': category,
      'severity': severity,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory IncidentEntry.fromJson(Map<String, dynamic> json) {
    return IncidentEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      category: json['category'] as String? ?? 'Outro',
      severity: json['severity'] as String? ?? 'Baixa',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Mapa para persistência no Cloud Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'category': category,
      'severity': severity,
      'description': description, // Guardada cifrada
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Cria instância a partir de documento do Cloud Firestore
  factory IncidentEntry.fromFirestore(String docId, Map<String, dynamic> data) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return IncidentEntry(
      id: docId,
      title: data['title'] as String? ?? '',
      date: parseDate(data['date']),
      category: data['category'] as String? ?? 'Outro',
      severity: data['severity'] as String? ?? 'Baixa',
      description: data['description'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  String encode() => jsonEncode(toJson());

  factory IncidentEntry.decode(String str) =>
      IncidentEntry.fromJson(jsonDecode(str) as Map<String, dynamic>);
}
