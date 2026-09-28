import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dermiq/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import 'legal_doc_screen.dart';

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

  /// Handle the Biometric Lock toggle. Enabling it first verifies a
  /// biometric/device credential is available and requires one successful
  /// auth to confirm; disabling always succeeds. The pref is persisted only
  /// when the (verified) new value should stick.
  Future<void> _toggleBiometric(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final n = ref.read(settingsProvider.notifier);

    // Turning OFF — no verification needed.
    if (!value) {
      n.edit((x) => x.copyWith(biometricLock: false));
      return;
    }

    // Turning ON — device must support it, and the user must pass once.
    final biometrics = BiometricService();
    final available = await biometrics.isAvailable();
    if (!context.mounted) return;
    if (!available) {
      AppSnackbar.error(
        context,
        'No biometrics or device passcode set up on this device.',
      );
      return; // stays off
    }

    final ok = await biometrics.authenticate(
      reason: 'Confirm to enable Biometric Lock',
    );
    if (!context.mounted) return;
    if (ok) {
      n.edit((x) => x.copyWith(biometricLock: true));
      AppSnackbar.success(context, 'Biometric Lock enabled.');
    } else {
      AppSnackbar.error(context, 'Authentication failed — lock not enabled.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppTopBar(title: l.privacyAndData),
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
                    l.privacyBanner,
                    style: AppTypography.bodySmall.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 18),

          AppSectionCard(title: l.dataUsage, children: [
            AppToggleTile(
              icon: Icons.bar_chart_rounded, color: AppColors.primary,
              label: l.analytics, subtitle: l.analyticsSubtitle,
              value: s.analytics,
              onChanged: (v) => n.edit((x) => x.copyWith(analytics: v)),
            ),
            AppToggleTile(
              icon: Icons.auto_awesome_rounded, color: const Color(0xFF8B5CF6),
              label: l.personalization, subtitle: l.personalizationSubtitle,
              value: s.personalization,
              onChanged: (v) => n.edit((x) => x.copyWith(personalization: v)),
            ),
            AppToggleTile(
              icon: Icons.share_rounded, color: const Color(0xFF06B6D4),
              label: l.shareWithPartners, subtitle: l.shareWithPartnersSubtitle,
              value: s.shareWithPartners,
              onChanged: (v) => n.edit((x) => x.copyWith(shareWithPartners: v)),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          AppSectionCard(title: l.security, children: [
            AppToggleTile(
              icon: Icons.fingerprint_rounded, color: AppColors.success,
              label: l.biometricLock, subtitle: l.biometricLockSubtitle,
              value: s.biometricLock,
              onChanged: (v) => _toggleBiometric(context, ref, v),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 140.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          AppSectionCard(title: l.yourData, children: [
            AppSettingsTile(
              icon: Icons.download_rounded, label: l.downloadMyData,
              onTap: () => _downloadData(context),
            ),
            AppSettingsTile(
              icon: Icons.delete_outline_rounded, label: l.deleteMyAccount,
              danger: true, onTap: () => _deleteAccount(context, ref), divider: false,
            ),
          ]).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          AppSectionCard(title: l.policies, children: [
            AppSettingsTile(
              icon: Icons.privacy_tip_outlined, label: l.privacyPolicy,
              onTap: () => openLegalDoc(context, terms: false),
            ),
            AppSettingsTile(
              icon: Icons.article_outlined, label: l.termsOfService,
              onTap: () => openLegalDoc(context, terms: true),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 260.ms, duration: 300.ms).slideY(begin: 0.03),
        ],
      ),
    );
  }
}
