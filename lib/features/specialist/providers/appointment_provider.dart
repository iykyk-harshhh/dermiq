import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/analytics_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/appointment_repository.dart';
import '../data/specialist_models.dart';

/// The user's appointments. Streams from Firestore (`users/{uid}/appointments`)
/// when signed in — showing the user's REAL list, including a genuinely empty
/// one (the screen renders its own empty state). The sample list is used only
/// for the signed-out / offline demo case, where there is no account to read.
class AppointmentNotifier extends Notifier<List<Appointment>> {
  AppointmentRepository get _repo => ref.read(appointmentRepositoryProvider);
  String? get _uid => ref.read(authStateProvider)?.id;

  @override
  List<Appointment> build() {
    final uid = ref.watch(authStateProvider)?.id;
    if (uid != null && _repo.isOnline) {
      // Signed in + online → the user's real appointments (may be empty).
      final sub = _repo.watch(uid).listen((appts) => state = appts);
      ref.onDispose(sub.cancel);
      return const <Appointment>[];
    }
    // Signed out / offline demo → sample data so the screen isn't blank.
    return List.of(myAppointmentsMock);
  }

  /// Books a consultation from the [draft] and persists it.
  Appointment book(BookingDraft draft) {
    final appt = Appointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      specialistId: draft.specialistId,
      startAt: draft.startAt,
      consultType: draft.consultType,
      durationMin: draft.durationMin,
      status: AppointmentStatus.upcoming,
      reason: draft.reason,
    );
    state = [appt, ...state];
    final uid = _uid;
    if (uid != null) _repo.save(uid, appt);
    ref.read(analyticsServiceProvider).logEvent('appointment_booked', {
      'specialist': draft.specialistId,
      'type': draft.consultType,
    });
    return appt;
  }

  void cancel(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(status: AppointmentStatus.cancelled) else a,
    ];
    final uid = _uid;
    if (uid != null) _repo.updateStatus(uid, id, AppointmentStatus.cancelled);
  }
}

final appointmentProvider =
    NotifierProvider<AppointmentNotifier, List<Appointment>>(
        AppointmentNotifier.new);
