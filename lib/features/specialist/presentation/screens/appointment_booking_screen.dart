import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/specialist_models.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String specialistId;
  const AppointmentBookingScreen({super.key, required this.specialistId});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String? _selectedTime;
  int _selectedDay = 0;
  int _consultType = 0;
  final _reasonCtrl = TextEditingController();

  late final List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    _days = List.generate(7, (i) => base.add(Duration(days: i)));
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _dayLabel(int i) {
    final d = _days[i];
    if (i == 0) return 'Today, ${monthDayLabel(d)}';
    if (i == 1) return 'Tomorrow, ${monthDayLabel(d)}';
    return '${weekdayShort(d)}, ${monthDayLabel(d)}';
  }

  void _confirm(Specialist s) {
    final type = consultTypes[_consultType];
    final draft = BookingDraft(
      specialistId: s.id,
      dateLabel: _dayLabel(_selectedDay),
      time: _selectedTime!,
      consultType: type,
      durationMin: consultDuration(type),
      fee: s.fee,
    );
    context.push('/specialist/${s.id}/confirmation', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final s = lookupSpecialist(widget.specialistId);
    final type = consultTypes[_consultType];

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('Book Appointment', style: AppTypography.h4),
        centerTitle: true,
      ),
      bottomNavigationBar: _ConfirmBar(
        enabled: _selectedTime != null,
        fee: s.fee,
        onConfirm: () => _confirm(s),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Specialist summary ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.dColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: context.dColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [s.color, s.color.withValues(alpha: 0.7)]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Text(s.initials,
                          style: AppTypography.labelLarge.copyWith(color: Colors.white))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: AppTypography.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(s.type,
                          style: AppTypography.caption.copyWith(color: s.color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 3),
                    Text('${s.rating}',
                        style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          // ── Consultation type ────────────────────────────────────────────
          _Card(
            title: 'Consultation Type',
            child: Row(
              children: List.generate(consultTypes.length, (i) {
                final active = i == _consultType;
                final t = consultTypes[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _consultType = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < consultTypes.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : context.dColors.surfaceDim,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: active ? AppColors.primary : Colors.transparent,
                            width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(consultIcon(t),
                              size: 20,
                              color: active ? AppColors.primary : context.dColors.textSecondary),
                          const SizedBox(height: 6),
                          Text(t,
                              style: AppTypography.caption.copyWith(
                                color: active ? AppColors.primary : context.dColors.textSecondary,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

          const SizedBox(height: 16),

          // ── Date picker ──────────────────────────────────────────────────
          _Card(
            title: 'Select Date',
            child: SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = i == _selectedDay;
                  final d = _days[i];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDay = i;
                      _selectedTime = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : context.dColors.surfaceDim,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: active ? AppColors.elevatedShadow : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(i == 0 ? 'Today' : weekdayShort(d),
                              style: AppTypography.caption.copyWith(
                                color: active
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : context.dColors.textTertiary,
                                fontSize: 10,
                              )),
                          const SizedBox(height: 4),
                          Text('${d.day}',
                              style: AppTypography.labelLarge.copyWith(
                                color: active ? Colors.white : context.dColors.textPrimary,
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ).animate().fadeIn(delay: 140.ms, duration: 300.ms),

          const SizedBox(height: 16),

          // ── Time slots ───────────────────────────────────────────────────
          _Card(
            title: 'Select Time',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: s.slots.map((t) {
                final active = _selectedTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : context.dColors.surfaceDim,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: active ? AppColors.primary : Colors.transparent,
                          width: 1.5),
                    ),
                    child: Text(t,
                        style: AppTypography.labelSmall.copyWith(
                          color: active ? AppColors.primary : context.dColors.textSecondary,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

          const SizedBox(height: 16),

          // ── Reason ───────────────────────────────────────────────────────
          _Card(
            title: 'Reason for Visit (optional)',
            child: TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              style: AppTypography.bodyMedium.copyWith(color: context.dColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Briefly describe your concern…',
                hintStyle: AppTypography.bodyMedium.copyWith(color: context.dColors.textTertiary),
                filled: true,
                fillColor: context.dColors.surfaceDim,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ).animate().fadeIn(delay: 260.ms, duration: 300.ms),

          const SizedBox(height: 16),

          // ── Summary ──────────────────────────────────────────────────────
          if (_selectedTime != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                      icon: consultIcon(type), label: type,
                      value: '${consultDuration(type)} min'),
                  const SizedBox(height: 10),
                  _SummaryRow(
                      icon: Icons.event_rounded,
                      label: _dayLabel(_selectedDay),
                      value: _selectedTime!),
                  Divider(color: context.dColors.borderLight, height: 24),
                  Row(
                    children: [
                      Text('Total', style: AppTypography.labelMedium),
                      const Spacer(),
                      Text('\$${s.fee.toStringAsFixed(0)}',
                          style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms),
        ],
      ),
    );
  }
}

// ── _ConfirmBar ───────────────────────────────────────────────────────────────

class _ConfirmBar extends StatelessWidget {
  final bool enabled;
  final double fee;
  final VoidCallback onConfirm;
  const _ConfirmBar({required this.enabled, required this.fee, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: enabled ? onConfirm : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 52,
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.gradientPrimary : null,
            color: enabled ? null : context.dColors.borderLight,
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(enabled ? Icons.check_rounded : Icons.access_time_rounded,
                  size: 18,
                  color: enabled ? Colors.white : context.dColors.textTertiary),
              const SizedBox(width: 8),
              Text(
                enabled ? 'Confirm Booking · \$${fee.toStringAsFixed(0)}' : 'Select a time slot',
                style: AppTypography.button.copyWith(
                    color: enabled ? Colors.white : context.dColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _SummaryRow ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTypography.bodySmall)),
        Text(value,
            style: AppTypography.labelMedium.copyWith(color: context.dColors.textPrimary)),
      ],
    );
  }
}

// ── _Card ─────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
