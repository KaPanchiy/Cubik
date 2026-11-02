import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/incident_model.dart';
import 'encryption_service.dart';
import 'secret_code_service.dart';

/// Repositório híbrido do Diário:
/// - Armazenamento local (SharedPreferences) para funcionamento offline imediato.
/// - Sincronização em nuvem (Cloud Firestore) em `users/{uid}/entries/{id}`.
/// - Cifra da descrição com o PIN do utilizador antes do envio para garantir privacidade absoluta.
class DiaryRepository {
  static const String _localEntriesKey = 'local_diary_incidents';

  /// Obtém o UID autenticado do Firebase (ou null se indisponível)
  static String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Coleção de ocorrências do utilizador no Firestore
  static CollectionReference<Map<String, dynamic>>? get _firestoreCollection {
    final uid = _currentUserId;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('entries');
  }

  /// Carrega todas as ocorrências (tenta Firestore primeiro; usa cache local offline)
  static Future<List<IncidentEntry>> getEntries() async {
    final pin = await SecretCodeService.getSecretCode();
    List<IncidentEntry> entries = [];

    // 1. Tentar ler da nuvem se autenticado
    final collection = _firestoreCollection;
    if (collection != null) {
      try {
        final snapshot = await collection.orderBy('date', descending: true).get();
        if (snapshot.docs.isNotEmpty) {
          entries = snapshot.docs.map((doc) {
            final entry = IncidentEntry.fromFirestore(doc.id, doc.data());
            // Decifrar descrição com o PIN
            final plainDesc = EncryptionService.decrypt(entry.description, pin);
            return entry.copyWith(description: plainDesc);
          }).toList();

          // Atualizar cache local com os dados decifrados
          await _saveToLocalCache(entries);
          return entries;
        }
      } catch (e) {
        debugPrint('Firestore offline ou inacessível, a usar cache local: $e');
      }
    }

    // 2. Fallback: ler do armazenamento local
    entries = await _loadFromLocalCache();
    return entries;
  }

  /// Guarda uma nova ocorrência (ou atualiza) localmente e na nuvem
  static Future<void> saveEntry(IncidentEntry entry) async {
    final pin = await SecretCodeService.getSecretCode();
    // Cifrar descrição com o PIN antes de persistir
    final encryptedDesc = EncryptionService.encrypt(entry.description, pin);
    final entryToCloud = entry.copyWith(description: encryptedDesc);

    // 1. Guardar localmente
    final currentEntries = await _loadFromLocalCache();
    final index = currentEntries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      currentEntries[index] = entry;
    } else {
      currentEntries.insert(0, entry);
    }
    await _saveToLocalCache(currentEntries);

    // 2. Sincronizar com Firestore em background sem bloquear a UI
    final collection = _firestoreCollection;
    if (collection != null) {
      try {
        await collection.doc(entry.id).set(entryToCloud.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erro ao sincronizar ocorrência no Firestore: $e');
      }
    }
  }

  /// Elimina uma ocorrência localmente e no Firestore
  static Future<void> deleteEntry(String id) async {
    // 1. Eliminar do cache local
    final currentEntries = await _loadFromLocalCache();
    currentEntries.removeWhere((e) => e.id == id);
    await _saveToLocalCache(currentEntries);

    // 2. Eliminar do Firestore
    final collection = _firestoreCollection;
    if (collection != null) {
      try {
        await collection.doc(id).delete();
      } catch (e) {
        debugPrint('Erro ao eliminar ocorrência no Firestore: $e');
      }
    }
  }

  // --- Funções auxiliares de cache local ---

  static Future<List<IncidentEntry>> _loadFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localEntriesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List list = jsonDecode(raw);
      return list.map((e) => IncidentEntry.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveToLocalCache(List<IncidentEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_localEntriesKey, raw);
  }
}
