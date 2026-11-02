import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'diary_repository.dart';

/// Serviço para gestão e sincronização da pontuação recorde (High Score).
/// - Guarda no SharedPreferences imediatamente para desempenho fluido do jogo offline.
/// - Sincroniza em background (não-bloqueante) com Cloud Firestore em `users/{uid}/stats/game`.
class ScoreService {
  static const String _highScoreKey = 'block_blast_high_score';

  /// Obtém o High Score guardado localmente e sincroniza em background com a nuvem
  static Future<int> getHighScore({void Function(int remoteScore)? onRemoteUpdated}) async {
    final prefs = await SharedPreferences.getInstance();
    int localScore = prefs.getInt(_highScoreKey) ?? 0;

    // Sincronização assíncrona não-bloqueante com Firestore
    DiaryRepository.ensureSignedIn().then((uid) {
      if (uid != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('stats')
            .doc('game')
            .get()
            .then((doc) {
          if (doc.exists && doc.data() != null) {
            final cloudScore = doc.data()?['highScore'] as int? ?? 0;
            if (cloudScore > localScore) {
              prefs.setInt(_highScoreKey, cloudScore);
              if (onRemoteUpdated != null) {
                onRemoteUpdated(cloudScore);
              }
            } else if (localScore > cloudScore) {
              saveHighScore(localScore);
            }
          } else if (localScore > 0) {
            saveHighScore(localScore);
          }
        }).catchError((e) {
          debugPrint('Firestore offline ao ler stats: $e');
        });
      }
    }).catchError((_) {});

    return localScore;
  }

  /// Guarda nova pontuação recorde localmente e sincroniza no Firestore de forma não-bloqueante
  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);

    // Sincronização em segundo plano não-bloqueante
    DiaryRepository.ensureSignedIn().then((uid) {
      if (uid != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('stats')
            .doc('game')
            .set({
          'highScore': score,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).catchError((e) {
          debugPrint('Erro ao sincronizar score no Firestore em background: $e');
        });
      }
    }).catchError((_) {});
  }
}
