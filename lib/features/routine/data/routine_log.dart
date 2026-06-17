import 'dart:convert';

import '../../../core/services/preferences_service.dart';
import 'routine_models.dart';

/// Per-date routine completion log: `yyyy-mm-dd` -> [amDone, pmDone].
///
/// This is the real source of truth the calendar colours each day from
/// (green = both, yellow = one, red = neither — only for days that have data).
/// On first use it seeds from [routineHistory] mapped onto the most recent real
/// dates, so a fresh install still shows a populated, realistic recent calendar;
/// from then on actual completions (logged via [routineLogSet]) take over.

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
      // fall through to reseed
    }
  }
  // Seed from the rolling routine history (index 0 = today, going back).
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final seed = <String, List<bool>>{};
  for (var i = 0; i < routineHistory.length; i++) {
    final d = today.subtract(Duration(days: i));
    final h = routineHistory[i];
    seed[routineDayKey(d)] = [h.amDone, h.pmDone];
  }
  PreferencesService.setRoutineLogJson(jsonEncode(seed));
  return seed;
}

/// Records today's (or [day]'s) AM/PM completion into the persisted log.
void routineLogSet(DateTime day, {required bool am, required bool pm}) {
  final log = routineLogLoad();
  log[routineDayKey(DateTime(day.year, day.month, day.day))] = [am, pm];
  PreferencesService.setRoutineLogJson(jsonEncode(log));
}
