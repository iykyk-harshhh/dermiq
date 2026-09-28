import '../../routine/data/routine_log.dart';

/// A single day in the calendar with routine-completion data.
class CalendarDay {
  final DateTime date;
  final bool amDone;
  final bool pmDone;
  final bool isFuture;
  final bool hasData; // true if this day has a real completion log entry
  final int? skinScore; // optional skin check-in score

  const CalendarDay({
    required this.date,
    required this.amDone,
    required this.pmDone,
    required this.isFuture,
    this.hasData = false,
    this.skinScore,
  });

  bool get bothDone => amDone && pmDone;
  bool get anyDone => amDone || pmDone;
  // Red only for past days we actually have data for and nothing was done —
  // days with no logged activity stay neutral (WHOOP-style).
  bool get missed => !isFuture && hasData && !amDone && !pmDone;
  bool get hasCheckIn => skinScore != null;
}

// ── Labels ──────────────────────────────────────────────────────────────────

const calMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const calMonthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const calWeekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

/// Monday-first weekday headers, used when the user's First-Day-of-Week
/// preference is "Monday".
const calWeekDaysMon = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// Weekday header row respecting the [mondayFirst] preference.
List<String> calWeekDaysFor({required bool mondayFirst}) =>
    mondayFirst ? calWeekDaysMon : calWeekDays;

const calWeekDaysFull = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
];

String calMonthLabel(DateTime month) =>
    '${calMonthNames[month.month - 1]} ${month.year}';

/// Number of empty leading cells before day 1 (Sunday-first grid).
int calLeadingBlanks(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  return first.weekday % 7; // Mon=1..Sun=7 → Sun=0
}

/// Number of empty leading cells before day 1, respecting the first-day-of-week
/// preference. Monday-first: Mon=0..Sun=6; Sunday-first: Sun=0..Sat=6.
int calLeadingBlanksFor(DateTime month, {required bool mondayFirst}) {
  final first = DateTime(month.year, month.month, 1);
  return mondayFirst ? first.weekday - 1 : first.weekday % 7;
}

int calDaysInMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0).day;

// ── Real per-date data (from the routine completion log) ──────────────────────

/// Builds the calendar for [month] from the real routine-completion log
/// (see `routine_log.dart`). Days with no logged activity are left neutral
/// (no colour); logged days are coloured green/yellow/red by completion.
List<CalendarDay> calGenerateMonth(
  DateTime month, {
  Map<String, List<bool>>? log,
  Map<String, int>? checkIns,
}) {
  final data = log ?? routineLogLoad();
  final checks = checkIns ?? checkInLogLoad();
  final days = calDaysInMonth(month);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final out = <CalendarDay>[];

  for (var d = 1; d <= days; d++) {
    final date = DateTime(month.year, month.month, d);
    final isFuture = date.isAfter(today);
    final key = routineDayKey(date);
    final entry = data[key];
    final hasData = entry != null && !isFuture;

    out.add(CalendarDay(
      date: date,
      amDone: hasData && entry[0],
      pmDone: hasData && entry[1],
      isFuture: isFuture,
      hasData: hasData,
      skinScore: isFuture ? null : checks[key],
    ));
  }
  return out;
}

/// Completion percentage (both AM+PM done) over days that have logged data.
double calCompletionRate(List<CalendarDay> days) {
  final logged = days.where((d) => d.hasData).toList();
  if (logged.isEmpty) return 0;
  final full = logged.where((d) => d.bothDone).length;
  return full / logged.length;
}

/// Count of days where both AM and PM were completed.
int calPerfectDays(List<CalendarDay> days) =>
    days.where((d) => d.bothDone).length;

/// Count of fully-missed past days.
int calMissedDays(List<CalendarDay> days) =>
    days.where((d) => d.missed).length;

/// Average skin check-in score this month.
int calAvgCheckIn(List<CalendarDay> days) {
  final scored = days.where((d) => d.hasCheckIn).map((d) => d.skinScore!);
  if (scored.isEmpty) return 0;
  return (scored.reduce((a, b) => a + b) / scored.length).round();
}

/// Current consecutive-day streak counting back from the most recent
/// non-future day with any routine logged.
int calCurrentStreak(List<CalendarDay> days) {
  final past = days.where((d) => !d.isFuture).toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // newest first
  var streak = 0;
  for (final d in past) {
    if (d.anyDone) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

/// Longest consecutive-day streak in the month.
int calBestStreak(List<CalendarDay> days) {
  final past = days.where((d) => !d.isFuture).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  var best = 0, cur = 0;
  for (final d in past) {
    if (d.anyDone) {
      cur++;
      if (cur > best) best = cur;
    } else {
      cur = 0;
    }
  }
  return best;
}
