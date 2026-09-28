import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';

/// Persists the user's streak state at `users/{uid}/streakState/current`.
///
/// Offline-first: SharedPreferences remains the local cache; this mirrors the
/// streak snapshot to Firestore when signed in + online, and no-ops otherwise.
class StreakRepository {
  StreakRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  DocumentReference<Map<String, dynamic>>? _doc(String uid) =>
      _db?.collection('users').doc(uid).collection('streakState').doc('current');

  /// Realtime streak-state document. Degrades to nothing on stream error.
  Stream<Map<String, dynamic>?> watch(String uid) {
    final doc = _doc(uid);
    if (doc == null) return const Stream.empty();
    return doc.snapshots().map((s) => s.data()).handleError((Object e) {
      debugPrint('[Streak] watch stream error: $e');
    });
  }

  Future<void> save(String uid, Map<String, dynamic> data) async {
    try {
      await _doc(uid)?.set(data);
    } catch (e) {
      debugPrint('[Streak] save failed: $e');
    }
  }
}

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.watch(firestoreProvider));
});
