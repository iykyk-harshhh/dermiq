import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/diq_logo.dart';
import '../../data/specialist_models.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final String specialistId;
  final BookingDraft? draft;
  const AppointmentConfirmationScreen({
    super.key,
    required this.specialistId,
    this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final s = lookupSpecialist(specialistId);
    final type = draft?.consultType ?? 'Video Call';
    final dateLabel = draft?.dateLabel ?? 'Today';
    final time = draft?.time ?? '10:30 AM';
    final duration = draft?.durationMin ?? consultDuration(type);
    final fee = draft?.fee ?? s.fee;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2EDFF), Color(0xFFE8DEFF), Color(0xFFD8C8FF), Color(0xFFCCB8F5)],
            stops: [0.0, 0.3, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                const SizedBox(height: 20),
                const DiqLogo(size: DiqLogoSize.small),
                const Spacer(flex: 1),

                // Success icon
                Container(
                  width: 96, height: 96,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF4ADE80)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                ).animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),

                const SizedBox(height: 26),

                Text('Appointment\nConfirmed!',
                        style: AppTypography.display.copyWith(
                            color: const Color(0xFF1E1B4B), height: 1.1),
                        textAlign: TextAlign.center)
                    .animate().fadeIn(duration: 500.ms, delay: 200.ms),

                const SizedBox(height: 12),
                Text(
                  'Your ${type.toLowerCase()} with ${s.name} is booked. We\'ll send a reminder before it starts.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: const Color(0xFF6B7280), height: 1.6),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms, delay: 280.ms),

                const SizedBox(height: 26),

                // Details card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: context.dColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        leading: _Avatar(specialist: s),
                        title: s.name,
                        subtitle: s.type,
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        title: dateLabel,
                        subtitle: time,
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(
                        icon: consultIcon(type),
                        title: type,
                        subtitle: '$duration minute session · \$${fee.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 360.ms).slideY(begin: 0.12),

                const Spacer(flex: 2),

                AppButton(
                  label: 'View My Appointments',
                  onPressed: () => context.go('/appointments'),
                  icon: const Icon(Icons.event_note_rounded, color: Colors.white, size: 18),
                ).animate().fadeIn(duration: 400.ms, delay: 460.ms),

                const SizedBox(height: 12),

                AppButton(
                  label: 'Back to Home',
                  onPressed: () => context.go('/home'),
                  isOutlined: true,
                ).animate().fadeIn(duration: 400.ms, delay: 520.ms),

                const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── _Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Specialist specialist;
  const _Avatar({required this.specialist});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [specialist.color, specialist.color.withValues(alpha: 0.7)]),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(specialist.initials,
            style: AppTypography.labelMedium.copyWith(color: Colors.white)),
      ),
    );
  }
}

// ── _DetailRow ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title, subtitle;
  const _DetailRow({
    this.icon,
    this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading ??
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(subtitle,
                  style: AppTypography.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
