import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../settings/providers/settings_provider.dart';

class UserPreferencesScreen extends ConsumerWidget {
  const UserPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Preferences'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Intro banner ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.dColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personalize how DermIQ reminds, alerts and measures things for you.',
                    style: AppTypography.bodySmall.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 18),

          // ── Reminders ────────────────────────────────────────────────────
          AppSectionCard(title: 'Routine Reminders', children: [
            AppToggleTile(
              icon: Icons.wb_sunny_rounded, color: const Color(0xFFF59E0B),
              label: 'AM Routine', subtitle: 'Morning nudge at 7:00 AM',
              value: s.amReminder,
              onChanged: (v) => n.edit((x) => x.copyWith(amReminder: v)),
            ),
            AppToggleTile(
              icon: Icons.nightlight_rounded, color: AppColors.primary,
              label: 'PM Routine', subtitle: 'Evening nudge at 9:30 PM',
              value: s.pmReminder,
              onChanged: (v) => n.edit((x) => x.copyWith(pmReminder: v)),
            ),
            AppToggleTile(
              icon: Icons.favorite_rounded, color: AppColors.success,
              label: 'Skin Check-In', subtitle: 'Daily mood & skin rating',
              value: s.checkInReminder,
              onChanged: (v) => n.edit((x) => x.copyWith(checkInReminder: v)),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 60.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── Notifications ────────────────────────────────────────────────
          AppSectionCard(title: 'Notifications', children: [
            AppToggleTile(
              icon: Icons.inventory_2_rounded, color: const Color(0xFFEC4899),
              label: 'Product Expiry Alerts', subtitle: 'Warn me before products expire',
              value: s.prefExpiryAlerts,
              onChanged: (v) => n.edit((x) => x.copyWith(prefExpiryAlerts: v)),
            ),
            AppToggleTile(
              icon: Icons.insights_rounded, color: AppColors.primary,
              label: 'Weekly Score Updates', subtitle: 'Your skin score summary',
              value: s.prefScoreUpdates,
              onChanged: (v) => n.edit((x) => x.copyWith(prefScoreUpdates: v)),
            ),
            AppToggleTile(
              icon: Icons.menu_book_rounded, color: const Color(0xFF06B6D4),
              label: 'Tips & Articles', subtitle: 'Skincare reads picked for you',
              value: s.tipsArticles,
              onChanged: (v) => n.edit((x) => x.copyWith(tipsArticles: v)),
            ),
            AppToggleTile(
              icon: Icons.event_note_rounded, color: const Color(0xFF8B5CF6),
              label: 'Appointment Reminders', subtitle: 'Before specialist consultations',
              value: s.appointmentReminders,
              onChanged: (v) => n.edit((x) => x.copyWith(appointmentReminders: v)),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 120.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── Units & region ───────────────────────────────────────────────
          AppSectionCard(title: 'Units & Region', children: [
            _ChoiceRow(
              label: 'Currency', options: const ['USD', 'EUR', 'GBP', 'INR'],
              value: s.currency, onSelect: (v) => n.edit((x) => x.copyWith(currency: v)),
            ),
            _ChoiceRow(
              label: 'Volume Units', options: const ['ml', 'oz'],
              value: s.volumeUnit, onSelect: (v) => n.edit((x) => x.copyWith(volumeUnit: v)),
            ),
            _ChoiceRow(
              label: 'First Day of Week', options: const ['Sunday', 'Monday'],
              value: s.firstDayOfWeek,
              onSelect: (v) => n.edit((x) => x.copyWith(firstDayOfWeek: v)),
            ),
            _ChoiceRow(
              label: 'Language', options: const ['English', 'Español', 'Français', 'हिन्दी'],
              value: s.language, onSelect: (v) => n.edit((x) => x.copyWith(language: v)),
              last: true,
            ),
          ]).animate().fadeIn(delay: 180.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── More settings ────────────────────────────────────────────────
          AppSectionCard(title: 'More Settings', children: [
            AppSettingsTile(
              icon: Icons.palette_outlined, label: 'Theme & Appearance',
              iconBackground: context.dColors.surfaceDim,
              onTap: () => context.push('/settings/theme'),
            ),
            AppSettingsTile(
              icon: Icons.notifications_none_rounded, label: 'Notification Settings',
              iconBackground: context.dColors.surfaceDim,
              onTap: () => context.push('/settings/notifications'),
            ),
            AppSettingsTile(
              icon: Icons.lock_outline_rounded, label: 'Privacy & Data',
              iconBackground: context.dColors.surfaceDim,
              onTap: () => context.push('/settings/privacy'), divider: false,
            ),
          ]).animate().fadeIn(delay: 240.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 18),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Text('Preferences are saved automatically',
                    style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ── _ChoiceRow — label + single-select chip group ────────────────────────────

class _ChoiceRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onSelect;
  final bool last;

  const _ChoiceRow({
    required this.label,
    required this.options,
    required this.value,
    required this.onSelect,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelMedium),
              const SizedBox(height: 10),
              AppChipGroup(
                options: options, selected: [value], singleSelect: true, onToggle: onSelect,
              ),
            ],
          ),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: context.dColors.borderLight, height: 1),
          ),
      ],
    );
  }
}
