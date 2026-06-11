import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'firebase_bootstrap.dart';

/// Typed access to the DermIQ Firestore layout. Per-user data lives in
/// subcollections under `users/{uid}` so security rules stay simple:
///
///   users/{uid}                         → UserModel
///   users/{uid}/products/{productId}    → ProductModel
///   users/{uid}/routines/{routineId}    → routine docs
///   users/{uid}/analysis/{analysisId}   → analysis docs
///   users/{uid}/checkIns/{checkInId}    → daily check-ins
class FirestoreRefs {
  FirestoreRefs(this.db);
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get users =>
      db.collection(AppConstants.usersCollection);

  DocumentReference<Map<String, dynamic>> user(String uid) => users.doc(uid);

  CollectionReference<Map<String, dynamic>> products(String uid) =>
      user(uid).collection(AppConstants.productsCollection);

  CollectionReference<Map<String, dynamic>> routines(String uid) =>
      user(uid).collection(AppConstants.routinesCollection);

  CollectionReference<Map<String, dynamic>> analysis(String uid) =>
      user(uid).collection(AppConstants.analysisCollection);

  CollectionReference<Map<String, dynamic>> checkIns(String uid) =>
      user(uid).collection(AppConstants.checkInsCollection);
}

/// The Firestore instance, or null when Firebase isn't configured.
final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  if (!FirebaseBootstrap.isAvailable) return null;
  final db = FirebaseFirestore.instance;
  db.settings = const Settings(persistenceEnabled: true);
  return db;
});

/// Typed refs, or null when Firebase isn't configured.
final firestoreRefsProvider = Provider<FirestoreRefs?>((ref) {
  final db = ref.watch(firestoreProvider);
  return db == null ? null : FirestoreRefs(db);
});
