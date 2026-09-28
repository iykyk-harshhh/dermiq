import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';

/// Persists the per-date routine-completion log and skin check-in scores at
/// `users/{uid}/calendarLog/current`.
///
/// Offline-first: SharedPreferences remains the local cache; this mirrors the
/// same maps to Firestore when signed in + online, and no-ops otherwise.
class CalendarRepository {
  CalendarRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  DocumentReference<Map<String, dynamic>>? _doc(String uid) =>
      _db?.collection('users').doc(uid).collection('calendarLog').doc('current');

  /// Realtime calendar-log document ({log: {...}, checkIns: {...}}).
  Stream<Map<String, dynamic>?> watch(String uid) {
    final doc = _doc(uid);
    if (doc == null) return const Stream.empty();
    return doc.snapshots().map((s) => s.data()).handleError((Object e) {
      debugPrint('[Calendar] watch stream error: $e');
    });
  }

  Future<void> save(String uid, Map<String, dynamic> data) async {
    try {
      await _doc(uid)?.set(data);
    } catch (e) {
      debugPrint('[Calendar] save failed: $e');
    }
  }
}

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(ref.watch(firestoreProvider));
});
