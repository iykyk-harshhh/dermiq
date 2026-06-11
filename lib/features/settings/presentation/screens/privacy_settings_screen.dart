import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  Future<void> _downloadData(BuildContext context) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Download My Data',
      message:
          'We\'ll prepare an export of your profile, routines and history and email it to you within 24 hours.',
      confirmLabel: 'Request',
    );
    if (ok == true && context.mounted) {
      AppSnackbar.success(context, 'Export requested — check your email soon.');
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Delete Account?',
      message:
          'This permanently erases your account, profile and data. This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep Account',
      danger: true,
    );
    if (ok != true) return;
    await ref.read(authProvider).deleteAccount();
    if (!context.mounted) return;
    // deleteAccount wipes local state (incl. onboarding + quiz flags), so a
    // deleted account restarts the full first-run flow: Splash → Onboarding → …
    context.go('/splash');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Privacy & Data'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Privacy banner ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your skin photos and health data are encrypted and never sold.',
                    style: AppTypography.bodySmall.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 18),

          AppSectionCard(title: 'Data Usage', children: [
            AppToggleTile(
              icon: Icons.bar_chart_rounded, color: AppColors.primary,
              label: 'Analytics', subtitle: 'Help us improve the app',
              value: s.analytics,
              onChanged: (v) => n.edit((x) => x.copyWith(analytics: v)),
            ),
            AppToggleTile(
              icon: Icons.auto_awesome_rounded, color: const Color(0xFF8B5CF6),
              label: 'Personalization', subtitle: 'Use my data for recommendations',
              value: s.personalization,
              onChanged: (v) => n.edit((x) => x.copyWith(personalization: v)),
            ),
            AppToggleTile(
              icon: Icons.share_rounded, color: const Color(0xFF06B6D4),
              label: 'Share with Partners', subtitle: 'Anonymized data for research',
              value: s.shareWithPartners,
              onChanged: (v) => n.edit((x) => x.copyWith(shareWithPartners: v)),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          AppSectionCard(title: 'Security', children: [
            AppToggleTile(
              icon: Icons.fingerprint_rounded, color: AppColors.success,
              label: 'Biometric Lock', subtitle: 'Require Face/Touch ID to open',
              value: s.biometricLock,
              onChanged: (v) => n.edit((x) => x.copyWith(biometricLock: v)),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 140.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          AppSectionCard(title: 'Your Data', children: [
            AppSettingsTile(
              icon: Icons.download_rounded, label: 'Download My Data',
              onTap: () => _downloadData(context),
            ),
            AppSettingsTile(
              icon: Icons.delete_outline_rounded, label: 'Delete My Account',
              danger: true, onTap: () => _deleteAccount(context, ref), divider: false,
            ),
          ]).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          AppSectionCard(title: 'Policies', children: [
            AppSettingsTile(
              icon: Icons.privacy_tip_outlined, label: 'Privacy Policy',
              onTap: () => AppSnackbar.show(context, 'Opening Privacy Policy…'),
            ),
            AppSettingsTile(
              icon: Icons.article_outlined, label: 'Terms of Service',
              onTap: () => AppSnackbar.show(context, 'Opening Terms of Service…'),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 260.ms, duration: 300.ms).slideY(begin: 0.03),
        ],
      ),
    );
  }
}
