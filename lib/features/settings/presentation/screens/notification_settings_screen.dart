import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final all = s.allNotifications;

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Master toggle ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: all ? AppColors.gradientHeroDark : null,
              color: all ? null : context.dColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: all ? AppColors.heroShadow : context.dColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: all
                        ? Colors.white.withValues(alpha: 0.15)
                        : context.dColors.surfaceDim,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    all ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                    color: all ? Colors.white : context.dColors.textTertiary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All Notifications',
                          style: AppTypography.labelLarge.copyWith(
                              color: all ? Colors.white : context.dColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(all ? 'You\'re all set to receive updates' : 'Everything is muted',
                          style: AppTypography.caption.copyWith(
                              color: all
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : context.dColors.textSecondary)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: all,
                  onChanged: (v) => n.edit((x) => x.copyWith(allNotifications: v)),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withValues(alpha: 0.35),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04),

          const SizedBox(height: 20),

          Opacity(
            opacity: all ? 1 : 0.4,
            child: IgnorePointer(
              ignoring: !all,
              child: Column(
                children: [
                  AppSectionCard(title: 'Routine', children: [
                    AppToggleTile(
                      icon: Icons.repeat_rounded, color: AppColors.primary,
                      label: 'Daily Routine Reminders', subtitle: 'AM & PM nudges',
                      value: s.routineReminders,
                      onChanged: (v) => n.edit((x) => x.copyWith(routineReminders: v)),
                    ),
                    AppToggleTile(
                      icon: Icons.insights_rounded, color: const Color(0xFF06B6D4),
                      label: 'Skin Score Updates', subtitle: 'Weekly progress recap',
                      value: s.skinScoreUpdates,
                      onChanged: (v) => n.edit((x) => x.copyWith(skinScoreUpdates: v)),
                      divider: false,
                    ),
                  ]).animate().fadeIn(delay: 80.ms, duration: 300.ms),

                  const SizedBox(height: 16),

                  AppSectionCard(title: 'Products', children: [
                    AppToggleTile(
                      icon: Icons.inventory_2_rounded, color: const Color(0xFFEC4899),
                      label: 'Expiry Alerts', subtitle: 'Before a product runs out',
                      value: s.productExpiryAlerts,
                      onChanged: (v) => n.edit((x) => x.copyWith(productExpiryAlerts: v)),
                      divider: false,
                    ),
                  ]).animate().fadeIn(delay: 140.ms, duration: 300.ms),

                  const SizedBox(height: 16),

                  AppSectionCard(title: 'Other', children: [
                    AppToggleTile(
                      icon: Icons.medical_services_rounded, color: const Color(0xFF8B5CF6),
                      label: 'Specialist Reminders', subtitle: 'Appointment alerts',
                      value: s.specialistReminders,
                      onChanged: (v) => n.edit((x) => x.copyWith(specialistReminders: v)),
                    ),
                    AppToggleTile(
                      icon: Icons.local_offer_rounded, color: const Color(0xFFF59E0B),
                      label: 'Promotions & Offers', subtitle: 'Deals and product launches',
                      value: s.promotions,
                      onChanged: (v) => n.edit((x) => x.copyWith(promotions: v)),
                      divider: false,
                    ),
                  ]).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                  const SizedBox(height: 16),

                  AppSectionCard(title: 'Quiet Hours', children: [
                    AppToggleTile(
                      icon: Icons.bedtime_rounded, color: const Color(0xFF6045CC),
                      label: 'Mute 10 PM – 7 AM',
                      subtitle: 'Pause non-urgent alerts overnight',
                      value: s.quietHours,
                      onChanged: (v) => n.edit((x) => x.copyWith(quietHours: v)),
                      divider: false,
                    ),
                  ]).animate().fadeIn(delay: 260.ms, duration: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
