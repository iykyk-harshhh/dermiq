import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/user_model.dart';
import '../firestore_service.dart';

/// CRUD + realtime access for `users/{uid}`.
class UserRepository {
  UserRepository(this._refs);
  final FirestoreRefs _refs;

  /// One-shot read.
  Future<UserModel?> fetch(String uid) async {
    final snap = await _refs.user(uid).get();
    final data = snap.data();
    return data == null ? null : UserModel.fromMap({...data, 'id': uid});
  }

  /// Realtime stream of the user document.
  Stream<UserModel?> watch(String uid) {
    return _refs.user(uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : UserModel.fromMap({...data, 'id': uid});
    });
  }

  /// Creates the user doc on first sign-up; merges if it already exists.
  Future<void> upsert(UserModel user) {
    return _refs.user(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  /// Ensures a document exists for a freshly authenticated user.
  Future<UserModel> ensureCreated({
    required String uid,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    final existing = await fetch(uid);
    if (existing != null) return existing;
    final user = UserModel(
      id: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );
    await upsert(user);
    return user;
  }

  Future<void> updateFields(String uid, Map<String, dynamic> fields) {
    return _refs.user(uid).set(fields, SetOptions(merge: true));
  }

  /// Persists quiz / profile answers (skin type, concerns, fitzpatrick, hair
  /// type, etc.) under `users/{uid}`. Offline-first: the caller keeps the local
  /// prefs cache as source-of-truth and mirrors here when signed in. Null values
  /// are stripped so a partially-answered quiz never wipes existing fields, and
  /// an all-null map is a no-op.
  Future<void> saveProfileAnswers(String uid, Map<String, dynamic> answers) {
    final clean = <String, dynamic>{
      for (final e in answers.entries)
        if (e.value != null) e.key: e.value,
    };
    if (clean.isEmpty) return Future.value();
    return _refs.user(uid).set(clean, SetOptions(merge: true));
  }

  /// Reads back the raw `users/{uid}` document so local quiz state can be
  /// hydrated on a new device / after reinstall. Returns null when no doc
  /// exists.
  Future<Map<String, dynamic>?> fetchProfileAnswers(String uid) async {
    final snap = await _refs.user(uid).get();
    return snap.data();
  }

  /// Persists the device FCM token under the user (array union).
  Future<void> saveFcmToken(String uid, String token) {
    return _refs.user(uid).set(
      {'fcmTokens': FieldValue.arrayUnion([token])},
      SetOptions(merge: true),
    );
  }

  /// Per-user subcollections the app writes under `users/{uid}`. Firestore does
  /// NOT cascade-delete subcollections when the parent doc is removed, so these
  /// must be cleared explicitly or they orphan forever. (Global collections like
  /// top-level `products` / `ingredients` and `products/{id}/reviews` are shared,
  /// not per-user, so they are intentionally excluded.)
  static const List<String> userSubcollections = [
    'products',
    'routines',
    'analysis',
    'checkIns',
    'shelf',
    'orders',
    'appointments',
  ];

  /// FREE client-side recursive delete of a user's subcollections. Pages through
  /// each collection in batches (Firestore batch cap is 500 writes) so large
  /// collections are handled without a Cloud Function. Best-effort: a failure on
  /// one collection is swallowed so the caller can still delete the parent doc
  /// and the Firebase user.
  Future<void> _deleteSubcollections(String uid) async {
    for (final name in userSubcollections) {
      final coll = _refs.user(uid).collection(name);
      try {
        while (true) {
          final snap = await coll.limit(400).get();
          if (snap.docs.isEmpty) break;
          final batch = _refs.db.batch();
          for (final doc in snap.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          if (snap.docs.length < 400) break;
        }
      } catch (_) {
        // Ignore and continue: partial cleanup is better than blocking deletion.
      }
    }
  }

  /// Deletes the user: clears all known subcollections first (Firestore has no
  /// cascade), then removes the top-level `users/{uid}` document.
  Future<void> delete(String uid) async {
    await _deleteSubcollections(uid);
    await _refs.user(uid).delete();
  }
}

final userRepositoryProvider = Provider<UserRepository?>((ref) {
  final refs = ref.watch(firestoreRefsProvider);
  return refs == null ? null : UserRepository(refs);
});
