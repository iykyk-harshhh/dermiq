import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../routine/data/routine_log.dart';
import '../data/calendar_repository.dart';

/// Immutable snapshot of the calendar's per-date data: routine completion log
/// (`yyyy-mm-dd` -> [amDone, pmDone]) and skin check-in scores (`key` -> 0–100).
class CalendarLogState {
  final Map<String, List<bool>> log;
  final Map<String, int> checkIns;

  const CalendarLogState({this.log = const {}, this.checkIns = const {}});

  CalendarLogState copyWith({
    Map<String, List<bool>>? log,
    Map<String, int>? checkIns,
  }) =>
      CalendarLogState(
        log: log ?? this.log,
        checkIns: checkIns ?? this.checkIns,
      );
}

/// Owns the calendar's completion log + check-in scores. SharedPreferences is
/// the local cache (works fully offline); when signed in + online it also
/// streams/writes the same maps to Firestore so history survives reinstall and
/// syncs across devices. Screens `ref.watch` this so completions logged
/// anywhere (routine detail, daily view) recolour the calendar reactively.
class CalendarLogNotifier extends Notifier<CalendarLogState> {
  CalendarRepository get _repo => ref.read(calendarRepositoryProvider);
  String? get _uid => ref.read(authStateProvider)?.id;

  @override
  CalendarLogState build() {
    // Local cache first — instant + offline.
    var s = CalendarLogState(log: routineLogLoad(), checkIns: checkInLogLoad());

    final uid = ref.watch(authStateProvider)?.id;
    if (uid != null && _repo.isOnline) {
      final sub = _repo.watch(uid).listen(
        (data) => _applyRemote(data),
        onError: (Object e) => debugPrint('[Calendar] watch error: $e'),
      );
      ref.onDispose(sub.cancel);
    }
    return s;
  }

  void _applyRemote(Map<String, dynamic>? data) {
    if (data == null) {
      // No remote doc yet — push the local cache up so it's backed up.
      _pushRemote();
      return;
    }
    final remoteLog = <String, List<bool>>{};
    final rawLog = data['log'];
    if (rawLog is Map) {
      rawLog.forEach((k, v) {
        if (v is List && v.length >= 2) {
          remoteLog['$k'] = [v[0] == true, v[1] == true];
        }
      });
    }
    final remoteCheck = <String, int>{};
    final rawCheck = data['checkIns'];
    if (rawCheck is Map) {
      rawCheck.forEach((k, v) {
        if (v is num) remoteCheck['$k'] = v.toInt();
      });
    }
    // Merge remote over local (last-write-wins per key), keeping any local-only
    // entries written while offline.
    final mergedLog = {...state.log, ...remoteLog};
    final mergedCheck = {...state.checkIns, ...remoteCheck};
    PreferencesService.setRoutineLogJson(jsonEncode(mergedLog));
    PreferencesService.setCheckInLogJson(jsonEncode(mergedCheck));
    state = CalendarLogState(log: mergedLog, checkIns: mergedCheck);
  }

  void _pushRemote() {
    final uid = _uid;
    if (uid == null) return;
    _repo.save(uid, {
      'log': state.log.map((k, v) => MapEntry(k, v)),
      'checkIns': state.checkIns,
    });
  }

  /// Records [day]'s AM/PM completion, updating cache + Firestore reactively.
  void setDay(DateTime day, {required bool am, required bool pm}) {
    final key = routineDayKey(DateTime(day.year, day.month, day.day));
    final log = {...state.log, key: [am, pm]};
    PreferencesService.setRoutineLogJson(jsonEncode(log));
    state = state.copyWith(log: log);
    _pushRemote();
  }

  /// Records a skin check-in [score] (0–100) for [day].
  void setCheckIn(DateTime day, int score) {
    final key = routineDayKey(DateTime(day.year, day.month, day.day));
    final checkIns = {...state.checkIns, key: score};
    PreferencesService.setCheckInLogJson(jsonEncode(checkIns));
    state = state.copyWith(checkIns: checkIns);
    _pushRemote();
  }
}

final calendarLogProvider =
    NotifierProvider<CalendarLogNotifier, CalendarLogState>(
        CalendarLogNotifier.new);
