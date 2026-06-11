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

  /// Persists the device FCM token under the user (array union).
  Future<void> saveFcmToken(String uid, String token) {
    return _refs.user(uid).set(
      {'fcmTokens': FieldValue.arrayUnion([token])},
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String uid) => _refs.user(uid).delete();
}

final userRepositoryProvider = Provider<UserRepository?>((ref) {
  final refs = ref.watch(firestoreRefsProvider);
  return refs == null ? null : UserRepository(refs);
});
