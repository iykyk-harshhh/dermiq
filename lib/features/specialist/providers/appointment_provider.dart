import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/analytics_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/appointment_repository.dart';
import '../data/specialist_models.dart';

/// The user's appointments. Streams from Firestore (`users/{uid}/appointments`)
/// when signed in; falls back to the sample list when signed out / offline so
/// the screen is never empty during the demo. A brand-new user with no booked
/// appointments also sees the sample list until they book their first one.
class AppointmentNotifier extends Notifier<List<Appointment>> {
  AppointmentRepository get _repo => ref.read(appointmentRepositoryProvider);
  String? get _uid => ref.read(authStateProvider)?.id;

  @override
  List<Appointment> build() {
    final uid = ref.watch(authStateProvider)?.id;
    if (uid != null && _repo.isOnline) {
      final sub = _repo.watch(uid).listen((appts) {
        state = appts.isNotEmpty ? appts : List.of(myAppointmentsMock);
      });
      ref.onDispose(sub.cancel);
    }
    return List.of(myAppointmentsMock);
  }

  /// Books a consultation from the [draft] and persists it.
  Appointment book(BookingDraft draft) {
    final appt = Appointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      specialistId: draft.specialistId,
      dateLabel: draft.dateLabel,
      time: draft.time,
      consultType: draft.consultType,
      durationMin: draft.durationMin,
      status: AppointmentStatus.upcoming,
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
