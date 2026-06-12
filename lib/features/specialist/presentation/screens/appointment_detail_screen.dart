import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/specialist_models.dart';

/// Full details for a single appointment — doctor, hospital, schedule and type,
/// with Reschedule / Cancel / View Profile / Get Directions actions.
class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

  ({Color color, String label, IconData icon}) get _statusMeta {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        return (color: AppColors.success, label: 'Upcoming', icon: Icons.schedule_rounded);
      case AppointmentStatus.completed:
        return (color: AppColors.primary, label: 'Completed', icon: Icons.check_circle_rounded);
      case AppointmentStatus.cancelled:
        return (color: AppColors.error, label: 'Cancelled', icon: Icons.cancel_rounded);
      case AppointmentStatus.missed:
        return (color: AppColors.warning, label: 'Missed', icon: Icons.event_busy_rounded);
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Cancel Appointment?',
      message:
          'Cancel your ${appointment.consultType.toLowerCase()} with ${appointment.specialist.name} on ${appointment.dateLabel}?',
      confirmLabel: 'Cancel It',
      cancelLabel: 'Keep',
      danger: true,
    );
    if (ok == true && context.mounted) context.pop('cancelled');
  }

  @override
  Widget build(BuildContext context) {
    final s = appointment.specialist;
    final meta = _statusMeta;
    final isUpcoming = appointment.status == AppointmentStatus.upcoming;

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('Appointment', style: AppTypography.h4),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // ── Doctor header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
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
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(s.initials,
                        style: AppTypography.h4.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: AppTypography.labelLarge.copyWith(color: Colors.white),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(s.type,
                          style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.8)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(meta.icon, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(meta.label,
                                style: AppTypography.caption.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.05),

          const SizedBox(height: 16),

          // ── Schedule ───────────────────────────────────────────────────────
          _InfoCard(
            title: 'Date & Time',
            icon: Icons.event_rounded,
            rows: [
              (label: 'Appointment ID', value: '#${appointment.id.toUpperCase()}'),
              (label: 'Date', value: appointment.dateLabel),
              (label: 'Time', value: appointment.time),
              (label: 'Duration', value: '${appointment.durationMin} min'),
            ],
          ).animate().fadeIn(delay: 60.ms, duration: 320.ms).slideY(begin: 0.04),

          const SizedBox(height: 12),

          // ── Appointment type ───────────────────────────────────────────────
          _InfoCard(
            title: 'Appointment Type',
            icon: consultIcon(appointment.consultType),
            rows: [
              (label: 'Mode', value: appointment.consultType),
              (label: 'Fee', value: '\$${s.fee.toStringAsFixed(0)}'),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 320.ms).slideY(begin: 0.04),

          const SizedBox(height: 12),

          // ── Doctor information ─────────────────────────────────────────────
          _InfoCard(
            title: 'Doctor Information',
            icon: Icons.medical_services_rounded,
            rows: [
              (label: 'Qualifications', value: s.qualifications),
              (label: 'Experience', value: '${s.yearsExp} years'),
              (label: 'Rating', value: '${s.rating} (${s.reviews} reviews)'),
            ],
          ).animate().fadeIn(delay: 140.ms, duration: 320.ms).slideY(begin: 0.04),

          const SizedBox(height: 12),

          // ── Hospital information ───────────────────────────────────────────
          _InfoCard(
            title: 'Hospital Information',
            icon: Icons.local_hospital_rounded,
            rows: [
              (label: 'Clinic', value: s.hospital),
              (label: 'Address', value: s.address),
              (label: 'Distance', value: '${s.distanceKm} km away'),
            ],
          ).animate().fadeIn(delay: 180.ms, duration: 320.ms).slideY(begin: 0.04),

          const SizedBox(height: 20),

          // ── Actions ────────────────────────────────────────────────────────
          if (isUpcoming) ...[
            Row(
              children: [
                Expanded(
                  child: _Action(
                    label: 'Reschedule',
                    icon: Icons.edit_calendar_rounded,
                    color: AppColors.primary,
                    filled: true,
                    onTap: () => context.push(AppRoutes.specialistDetail(s.id)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Action(
                    label: 'Cancel',
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    filled: false,
                    onTap: () => _confirmCancel(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _Action(
            label: 'View Specialist Profile',
            icon: Icons.person_rounded,
            color: AppColors.primary,
            filled: false,
            onTap: () => context.push(AppRoutes.specialistDetail(s.id)),
          ),
          const SizedBox(height: 12),
          _Action(
            label: 'Get Directions',
            icon: Icons.near_me_rounded,
            color: const Color(0xFF0EA5E9),
            filled: false,
            onTap: () => AppSnackbar.show(
                context, 'Opening directions to ${s.hospital}…'),
          ),
          const SizedBox(height: 12),
          _Action(
            label: 'Add to Calendar',
            icon: Icons.calendar_month_rounded,
            color: AppColors.primary,
            filled: false,
            onTap: () => AppSnackbar.show(context,
                'Added to your calendar — ${appointment.dateLabel}, ${appointment.time}'),
          ),
        ],
      ),
    );
  }
}

// ── _InfoCard ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<({String label, String value})> rows;
  const _InfoCard({required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTypography.labelMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(r.label,
                          style: AppTypography.caption
                              .copyWith(color: context.dColors.textTertiary)),
                    ),
                    Expanded(
                      child: Text(r.value,
                          style: AppTypography.bodySmall.copyWith(
                              color: context.dColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── _Action ───────────────────────────────────────────────────────────────────

class _Action extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _Action({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: filled ? Colors.white : color),
            const SizedBox(width: 8),
            Text(label,
                style: AppTypography.button
                    .copyWith(color: filled ? Colors.white : color)),
          ],
        ),
      ),
    );
  }
}
