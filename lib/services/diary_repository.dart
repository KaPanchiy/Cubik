import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/incident_model.dart';
import 'encryption_service.dart';

/// Repositório híbrido do Diário:
/// - Armazenamento local (SharedPreferences) 100% cifrado com AES-256 para funcionamento offline imediato.
/// - Sincronização assíncrona não bloqueante em nuvem (Cloud Firestore) em `users/{uid}/entries/{id}`.
/// - Cifra AES-256 com chave no Keystore/Keychain do dispositivo antes do envio.
class DiaryRepository {
  static const String _localEntriesKey = 'local_diary_incidents_enc';

  /// Garante que o utilizador está autenticado (mesmo se o app abriu sem rede na primeira vez)
  static Future<String?> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      return auth.currentUser!.uid;
    }
    try {
      final cred = await auth.signInAnonymously();
      return cred.user?.uid;
    } catch (e) {
      debugPrint('Tentativa de autenticação anónima falhou (offline): $e');
      return null;
    }
  }

  /// Coleção de ocorrências do utilizador no Firestore
  static Future<CollectionReference<Map<String, dynamic>>?> get _firestoreCollection async {
    final uid = await ensureSignedIn();
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('entries');
  }

  /// Carrega todas as ocorrências (tenta Firestore se houver rede; usa cache local cifrado como fallback seguro)
  static Future<List<IncidentEntry>> getEntries() async {
    List<IncidentEntry> entries = [];

    // 1. Tentar ler da nuvem se autenticado e com rede
    try {
      final collection = await _firestoreCollection;
      if (collection != null) {
        final snapshot = await collection.orderBy('date', descending: true).get();
        if (snapshot.docs.isNotEmpty) {
          final cloudEntries = <IncidentEntry>[];
          for (final doc in snapshot.docs) {
            final entry = IncidentEntry.fromFirestore(doc.id, doc.data());
            // Decifrar descrição com AES-256 do Keystore
            final plainDesc = await EncryptionService.decrypt(entry.description);
            cloudEntries.add(entry.copyWith(description: plainDesc));
          }

          if (cloudEntries.isNotEmpty) {
            // Atualizar cache local seguro
            await _saveToLocalCache(cloudEntries);
            return cloudEntries;
          }
        }
      }
    } catch (e) {
      debugPrint('Firestore offline ao carregar diário, a recorrer à cache local: $e');
    }

    // 2. Fallback imediato: ler do armazenamento local cifrado
    entries = await _loadFromLocalCache();
    return entries;
  }

  /// Guarda uma nova ocorrência (ou atualiza) localmente e na nuvem de forma não-bloqueante
  static Future<void> saveEntry(IncidentEntry entry, {bool isNew = true}) async {
    // 1. Guardar localmente de imediato (UI responde instantaneamente mesmo sem rede)
    final currentEntries = await _loadFromLocalCache();
    final index = currentEntries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      currentEntries[index] = entry;
    } else {
      currentEntries.insert(0, entry);
    }
    await _saveToLocalCache(currentEntries);

    // 2. Cifrar com AES-256 e sincronizar com Firestore em segundo plano (não bloqueia a UI nem falha offline)
    _syncToCloudInBackground(entry, isNew: isNew);
  }

  static void _syncToCloudInBackground(IncidentEntry entry, {required bool isNew}) async {
    try {
      final encryptedDesc = await EncryptionService.encrypt(entry.description);
      final entryToCloud = entry.copyWith(description: encryptedDesc);

      final collection = await _firestoreCollection;
      if (collection != null) {
        collection
            .doc(entry.id)
            .set(entryToCloud.toFirestore(isNew: isNew), SetOptions(merge: true))
            .catchError((e) {
          debugPrint('Sincronização em background falhou (persistência offline do Firestore ativa): $e');
        });
      }
    } catch (e) {
      debugPrint('Erro ao preparar sincronização em background: $e');
    }
  }

  /// Elimina uma ocorrência localmente e no Firestore de forma não-bloqueante
  static Future<void> deleteEntry(String id) async {
    // 1. Eliminar do cache local de imediato
    final currentEntries = await _loadFromLocalCache();
    currentEntries.removeWhere((e) => e.id == id);
    await _saveToLocalCache(currentEntries);

    // 2. Eliminar do Firestore em background
    _firestoreCollection.then((collection) {
      if (collection != null) {
        collection.doc(id).delete().catchError((e) {
          debugPrint('Erro ao eliminar no Firestore em background: $e');
        });
      }
    }).catchError((e) {
      debugPrint('Erro ao obter coleção no delete: $e');
    });
  }

  // --- Funções auxiliares de cache local cifrado ---

  static Future<List<IncidentEntry>> _loadFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localEntriesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      // O cache local está cifrado com AES-256
      final decryptedJson = await EncryptionService.decrypt(raw);
      final List list = jsonDecode(decryptedJson);
      return list.map((e) => IncidentEntry.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveToLocalCache(List<IncidentEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = jsonEncode(entries.map((e) => e.toJson()).toList());
    // Cifra o blob local antes de gravar no SharedPreferences
    final encryptedBlob = await EncryptionService.encrypt(rawJson);
    await prefs.setString(_localEntriesKey, encryptedBlob);
  }
}
