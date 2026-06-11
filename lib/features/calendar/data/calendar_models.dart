/// A single day in the calendar with routine-completion data.
class CalendarDay {
  final DateTime date;
  final bool amDone;
  final bool pmDone;
  final bool isFuture;
  final int? skinScore; // optional skin check-in score

  const CalendarDay({
    required this.date,
    required this.amDone,
    required this.pmDone,
    required this.isFuture,
    this.skinScore,
  });

  bool get bothDone => amDone && pmDone;
  bool get anyDone => amDone || pmDone;
  bool get missed => !isFuture && !amDone && !pmDone;
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

int calDaysInMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0).day;

// ── Deterministic mock data ───────────────────────────────────────────────────

/// Generates routine-completion data for [month]. Past days follow a
/// deterministic pattern (~80% AM, ~70% PM); future days are empty.
List<CalendarDay> calGenerateMonth(DateTime month) {
  final days = calDaysInMonth(month);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final out = <CalendarDay>[];

  for (var d = 1; d <= days; d++) {
    final date = DateTime(month.year, month.month, d);
    final isFuture = date.isAfter(today);

    var am = false, pm = false;
    int? score;
    if (!isFuture) {
      final seed = (d * 7) % 10;
      am = seed != 3 && seed != 8;             // skip a couple AM days
      pm = seed != 1 && seed != 6 && seed != 8; // skip a few PM days
      // Skin check-ins every 5th day
      if (d % 5 == 0) score = 70 + ((d * 3) % 26);
      // Make "today" feel active
      final isToday = date.isAtSameMomentAs(today);
      if (isToday) {
        am = true;
        pm = false;
      }
    }

    out.add(CalendarDay(
      date: date, amDone: am, pmDone: pm, isFuture: isFuture, skinScore: score,
    ));
  }
  return out;
}

/// Completion percentage (both AM+PM done) over non-future days.
double calCompletionRate(List<CalendarDay> days) {
  final past = days.where((d) => !d.isFuture).toList();
  if (past.isEmpty) return 0;
  final full = past.where((d) => d.bothDone).length;
  return full / past.length;
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
