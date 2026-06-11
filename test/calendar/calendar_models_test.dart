import 'package:flutter_test/flutter_test.dart';
import 'package:dermiq/features/calendar/data/calendar_models.dart';

void main() {
  // A fully-past month so every day is non-future (deterministic).
  final feb24 = DateTime(2024, 2);

  test('calDaysInMonth handles leap February', () {
    expect(calDaysInMonth(feb24), 29);
    expect(calDaysInMonth(DateTime(2023, 2)), 28);
    expect(calDaysInMonth(DateTime(2024, 4)), 30);
  });

  test('calMonthLabel formats month + year', () {
    expect(calMonthLabel(feb24), 'February 2024');
  });

  test('calLeadingBlanks places day 1 on the right weekday', () {
    // 1 Feb 2024 is a Thursday (weekday 4) → 4 leading blanks (Sun-first).
    expect(calLeadingBlanks(feb24), 4);
  });

  test('calGenerateMonth returns one entry per day', () {
    final days = calGenerateMonth(feb24);
    expect(days.length, 29);
    expect(days.every((d) => !d.isFuture), isTrue);
  });

  test('completion rate is a valid fraction', () {
    final days = calGenerateMonth(feb24);
    final rate = calCompletionRate(days);
    expect(rate, inInclusiveRange(0.0, 1.0));
  });

  test('streaks are non-negative and bounded', () {
    final days = calGenerateMonth(feb24);
    final current = calCurrentStreak(days);
    final best = calBestStreak(days);
    expect(current, greaterThanOrEqualTo(0));
    expect(best, greaterThanOrEqualTo(current));
    expect(best, lessThanOrEqualTo(days.length));
  });

  test('perfect + missed day counts stay within range', () {
    final days = calGenerateMonth(feb24);
    expect(calPerfectDays(days), inInclusiveRange(0, days.length));
    expect(calMissedDays(days), inInclusiveRange(0, days.length));
  });
}
