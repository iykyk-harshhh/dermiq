import 'dart:convert';

import '../../../core/services/preferences_service.dart';

/// Per-date routine completion log: `yyyy-mm-dd` -> [amDone, pmDone].
///
/// This is the real source of truth the calendar colours each day from
/// (green = both, yellow = one, red = neither — only for days that have data).
/// A fresh install starts empty and truthful: days colour in only as real
/// completions are logged (via [routineLogSet]). No fabricated seed history.

String routineDayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Map<String, List<bool>> routineLogLoad() {
  final raw = PreferencesService.routineLogJson;
  if (raw != null && raw.isNotEmpty) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) {
        final list = v as List;
        return MapEntry(k, [list[0] == true, list[1] == true]);
      });
    } catch (_) {
      // Corrupt payload → truthful empty log.
    }
  }
  return <String, List<bool>>{};
}

/// Records today's (or [day]'s) AM/PM completion into the persisted log.
void routineLogSet(DateTime day, {required bool am, required bool pm}) {
  final log = routineLogLoad();
  log[routineDayKey(DateTime(day.year, day.month, day.day))] = [am, pm];
  PreferencesService.setRoutineLogJson(jsonEncode(log));
}

/// Loads the per-date skin check-in scores {`yyyy-mm-dd`: score(0–100)}.
Map<String, int> checkInLogLoad() {
  final raw = PreferencesService.checkInLogJson;
  if (raw != null && raw.isNotEmpty) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      // Corrupt payload → empty.
    }
  }
  return <String, int>{};
}

/// Records a skin check-in [score] (0–100) for [day].
void checkInLogSet(DateTime day, int score) {
  final log = checkInLogLoad();
  log[routineDayKey(DateTime(day.year, day.month, day.day))] = score;
  PreferencesService.setCheckInLogJson(jsonEncode(log));
}
