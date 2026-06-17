import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';
import 'specialist_models.dart';

/// Persists a user's booked consultations at `users/{uid}/appointments/{id}`.
///
/// No-ops / empty stream when Firebase is unavailable, so the booking flow keeps
/// working offline (appointments then live only in memory for the session).
class AppointmentRepository {
  AppointmentRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  CollectionReference<Map<String, dynamic>>? _col(String uid) =>
      _db?.collection('users').doc(uid).collection('appointments');

  /// Realtime appointments, newest booking first.
  Stream<List<Appointment>> watch(String uid) {
    final col = _col(uid);
    if (col == null) return const Stream.empty();
    return col.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => Appointment.fromMap(d.data())).toList(),
        );
  }

  Future<void> save(String uid, Appointment appt) async {
    await _col(uid)?.doc(appt.id).set(appt.toMap());
  }

  Future<void> updateStatus(
      String uid, String id, AppointmentStatus status) async {
    await _col(uid)?.doc(id).set({'status': status.name}, SetOptions(merge: true));
  }
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(ref.watch(firestoreProvider));
});
