import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/calendar_models.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  late DateTime _today;
  late List<CalendarDay> _days;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _month = DateTime(now.year, now.month);
    _selected = _today;
    _days = calGenerateMonth(_month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _days = calGenerateMonth(_month);
      // Keep selection valid
      final dim = calDaysInMonth(_month);
      final day = _selected.day > dim ? dim : _selected.day;
      _selected = DateTime(_month.year, _month.month, day);
    });
  }

  CalendarDay? get _selectedDay {
    for (final d in _days) {
      if (d.date.year == _selected.year &&
          d.date.month == _selected.month &&
          d.date.day == _selected.day) {
        return d;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final streak = calCurrentStreak(calGenerateMonth(DateTime(_today.year, _today.month)));
    final rate = calCompletionRate(_days);

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                            color: context.dColors.surfaceDim,
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.arrow_back_rounded,
                            size: 20, color: context.dColors.textPrimary),
                      ),
                    ),
                    const Spacer(),
                    Text('Calendar', style: AppTypography.h4),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/calendar/reminders'),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                            color: context.dColors.surfaceDim,
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.notifications_none_rounded,
                            size: 20, color: context.dColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Summary hero ─────────────────────────────────────────
                  _SummaryHero(streak: streak, rate: rate, monthDays: _days)
                      .animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

                  const SizedBox(height: 16),

                  // ── Quick links ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _QuickLink(
                          icon: Icons.insights_rounded,
                          label: 'Monthly\nProgress',
                          color: AppColors.primary,
                          onTap: () => context.push('/calendar/monthly'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickLink(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Streak\nTracking',
                          color: const Color(0xFFFF6B7A),
                          onTap: () => context.push('/calendar/streak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickLink(
                          icon: Icons.alarm_rounded,
                          label: 'Reminder\nSettings',
                          color: const Color(0xFFF59E0B),
                          onTap: () => context.push('/calendar/reminders'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                  const SizedBox(height: 20),

                  // ── Month switcher ───────────────────────────────────────
                  Row(
                    children: [
                      Text(calMonthLabel(_month), style: AppTypography.h4),
                      const Spacer(),
                      _NavBtn(
                          icon: Icons.chevron_left_rounded,
                          onTap: () => _changeMonth(-1)),
                      const SizedBox(width: 8),
                      _NavBtn(
                          icon: Icons.chevron_right_rounded,
                          onTap: () => _changeMonth(1)),
                    ],
                  ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                  const SizedBox(height: 12),

                  // ── Calendar grid ────────────────────────────────────────
                  _MonthGrid(
                    month: _month,
                    days: _days,
                    today: _today,
                    selected: _selected,
                    onSelect: (d) => setState(() => _selected = d),
                  ).animate().fadeIn(delay: 180.ms, duration: 350.ms),

                  const SizedBox(height: 16),

                  // ── Legend ───────────────────────────────────────────────
                  _Legend()
                      .animate().fadeIn(delay: 220.ms, duration: 300.ms),

                  const SizedBox(height: 22),

                  // ── Selected-day detail ──────────────────────────────────
                  Row(
                    children: [
                      Text(
                        _isToday(_selected)
                            ? 'Today'
                            : '${calWeekDaysFull[_selected.weekday % 7]}, ${calMonthShort[_selected.month - 1]} ${_selected.day}',
                        style: AppTypography.labelLarge,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/calendar/daily'),
                        child: Text('Open ›',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms, duration: 300.ms),

                  const SizedBox(height: 12),

                  _DayDetail(day: _selectedDay, onOpen: () => context.push('/calendar/daily'))
                      .animate().fadeIn(delay: 290.ms, duration: 350.ms).slideY(begin: 0.04),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime d) =>
      d.year == _today.year && d.month == _today.month && d.day == _today.day;
}

// ── _SummaryHero ──────────────────────────────────────────────────────────────

class _SummaryHero extends StatelessWidget {
  final int streak;
  final double rate;
  final List<CalendarDay> monthDays;
  const _SummaryHero({required this.streak, required this.rate, required this.monthDays});

  @override
  Widget build(BuildContext context) {
    final perfect = calPerfectDays(monthDays);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.heroShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeroStat(
              icon: '🔥',
              value: '$streak',
              unit: 'day streak',
            ),
          ),
          Container(width: 1, height: 44, color: Colors.white.withValues(alpha: 0.15)),
          Expanded(
            child: _HeroStat(
              icon: '✓',
              value: '${(rate * 100).round()}%',
              unit: 'completion',
            ),
          ),
          Container(width: 1, height: 44, color: Colors.white.withValues(alpha: 0.15)),
          Expanded(
            child: _HeroStat(
              icon: '⭐',
              value: '$perfect',
              unit: 'perfect days',
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String icon, value, unit;
  const _HeroStat({required this.icon, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(value, style: AppTypography.metricSmall.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text(unit,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
      ],
    );
  }
}

// ── _QuickLink ────────────────────────────────────────────────────────────────

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                    color: context.dColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}

// ── _NavBtn ───────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: context.dColors.textPrimary),
        ),
      );
}

// ── _MonthGrid ────────────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final List<CalendarDay> days;
  final DateTime today;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({
    required this.month,
    required this.days,
    required this.today,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final blanks = calLeadingBlanks(month);
    final total = blanks + days.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: calWeekDays
                .map((d) => Expanded(
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                              color: context.dColors.textTertiary,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.82,
            ),
            itemCount: total,
            itemBuilder: (_, i) {
              if (i < blanks) return const SizedBox.shrink();
              final day = days[i - blanks];
              final isToday = day.date.year == today.year &&
                  day.date.month == today.month &&
                  day.date.day == today.day;
              final isSelected = day.date.year == selected.year &&
                  day.date.month == selected.month &&
                  day.date.day == selected.day;
              return _DayCell(
                day: day,
                isToday: isToday,
                isSelected: isSelected,
                onTap: () => onSelect(day.date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final CalendarDay day;
  final bool isToday, isSelected;
  final VoidCallback onTap;
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isSelected
        ? AppColors.primary
        : day.bothDone
            ? AppColors.success.withValues(alpha: 0.18)
            : day.anyDone
                ? AppColors.warning.withValues(alpha: 0.18)
                : day.missed
                    ? AppColors.error.withValues(alpha: 0.14)
                    : Colors.transparent;

    final textColor = isSelected
        ? Colors.white
        : day.isFuture
            ? context.dColors.textTertiary
            : isToday
                ? AppColors.primary
                : context.dColors.textPrimary;

    return GestureDetector(
      onTap: day.isFuture ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${day.date.day}',
                    style: AppTypography.bodySmall.copyWith(
                      color: textColor,
                      fontWeight: (isToday || isSelected)
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 13,
                    )),
              ),
            ),
            const SizedBox(height: 3),
            // AM/PM dots
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniDot(active: day.amDone, selected: isSelected),
                const SizedBox(width: 3),
                _MiniDot(active: day.pmDone, selected: isSelected),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDot extends StatelessWidget {
  final bool active, selected;
  const _MiniDot({required this.active, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (active ? Colors.white : Colors.white.withValues(alpha: 0.3))
        : (active ? AppColors.success : context.dColors.borderMedium);
    return Container(
      width: 4, height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── _Legend ───────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegItem(color: AppColors.success.withValues(alpha: 0.18), label: 'Full (AM+PM)'),
        _LegItem(color: AppColors.warning.withValues(alpha: 0.18), label: 'Partial'),
        _LegItem(color: AppColors.error.withValues(alpha: 0.14), label: 'Missed'),
        _LegItem(color: AppColors.primary, label: 'Selected'),
      ],
    );
  }
}

class _LegItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: context.dColors.textSecondary, fontSize: 11)),
        ],
      );
}

// ── _DayDetail ────────────────────────────────────────────────────────────────

class _DayDetail extends StatelessWidget {
  final CalendarDay? day;
  final VoidCallback onOpen;
  const _DayDetail({required this.day, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final d = day;
    if (d == null || d.isFuture) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Row(
          children: [
            Icon(Icons.event_available_rounded,
                color: context.dColors.textTertiary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Nothing scheduled yet for this day.',
                  style: AppTypography.bodySmall),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        children: [
          _RoutineRow(
            label: 'AM Routine',
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xFFF59E0B),
            done: d.amDone,
            onTap: onOpen,
          ),
          Divider(color: context.dColors.borderLight, height: 20),
          _RoutineRow(
            label: 'PM Routine',
            icon: Icons.nightlight_rounded,
            color: AppColors.primary,
            done: d.pmDone,
            onTap: onOpen,
          ),
          if (d.hasCheckIn) ...[
            Divider(color: context.dColors.borderLight, height: 20),
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: AppColors.success, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Skin Check-In',
                      style: AppTypography.labelMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${d.skinScore}/100',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.success, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RoutineRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool done;
  final VoidCallback onTap;
  const _RoutineRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTypography.labelMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: done
                  ? AppColors.success.withValues(alpha: 0.1)
                  : context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 13,
                  color: done ? AppColors.success : context.dColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(done ? 'Done' : 'Missed',
                    style: AppTypography.caption.copyWith(
                        color: done ? AppColors.success : context.dColors.textTertiary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
