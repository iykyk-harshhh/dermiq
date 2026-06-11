import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Sign Out?',
      message: 'You can sign back in anytime.',
      confirmLabel: 'Sign Out',
      danger: true,
    );
    if (confirmed != true) return;
    await ref.read(authProvider).signOut();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final name = user?.displayName ?? 'Sarah Johnson';
    final email = user?.email ?? 'sarah.johnson@email.com';

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Profile header ───────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.gradientHeroDark,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppColors.heroShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [Color(0xFF8B6FEA), Color(0xFFA78BFA)]),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: AppTypography.h4.copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                        const SizedBox(height: 3),
                        Text(email,
                            style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.75)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.8), size: 20),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04),

          const SizedBox(height: 20),

          // ── Account ──────────────────────────────────────────────────────
          AppSectionCard(title: 'Account', children: [
            AppSettingsTile(
              icon: Icons.face_retouching_natural_rounded, iconColor: AppColors.primary,
              label: 'Skin Profile', onTap: () => context.push('/profile/edit-skin'),
            ),
            AppSettingsTile(
              icon: Icons.cut_rounded, iconColor: const Color(0xFFEC4899),
              label: 'Hair Profile', onTap: () => context.push('/profile/edit-hair'),
            ),
            AppSettingsTile(
              icon: Icons.tune_rounded, iconColor: const Color(0xFF06B6D4),
              label: 'Preferences', onTap: () => context.push('/profile/preferences'),
            ),
            AppSettingsTile(
              icon: Icons.event_note_rounded, iconColor: const Color(0xFF8B5CF6),
              label: 'My Appointments', onTap: () => context.push('/appointments'),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── App ──────────────────────────────────────────────────────────
          AppSectionCard(title: 'App', children: [
            AppSettingsTile(
              icon: Icons.palette_outlined, iconColor: const Color(0xFFF59E0B),
              label: 'Theme & Appearance', value: 'Light',
              onTap: () => context.push('/settings/theme'),
            ),
            AppSettingsTile(
              icon: Icons.notifications_none_rounded, iconColor: AppColors.primary,
              label: 'Notifications', onTap: () => context.push('/settings/notifications'),
            ),
            AppSettingsTile(
              icon: Icons.lock_outline_rounded, iconColor: AppColors.success,
              label: 'Privacy & Data', onTap: () => context.push('/settings/privacy'),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 140.ms, duration: 350.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── Support ──────────────────────────────────────────────────────
          AppSectionCard(title: 'Support', children: [
            AppSettingsTile(
              icon: Icons.help_outline_rounded, iconColor: const Color(0xFF0EA5E9),
              label: 'Help & Support', onTap: () => context.push('/settings/help'),
            ),
            AppSettingsTile(
              icon: Icons.info_outline_rounded, iconColor: AppColors.primary,
              label: 'About DermIQ', onTap: () => context.push('/settings/about'),
            ),
            AppSettingsTile(
              icon: Icons.star_outline_rounded, iconColor: const Color(0xFFF59E0B),
              label: 'Rate the App', divider: false,
              onTap: () => AppSnackbar.show(context, 'Thanks! This would open the app store.'),
            ),
          ]).animate().fadeIn(delay: 200.ms, duration: 350.ms).slideY(begin: 0.03),

          const SizedBox(height: 20),

          // ── Sign out ─────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => _signOut(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: context.dColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 19),
                  const SizedBox(width: 8),
                  Text('Sign Out',
                      style: AppTypography.button.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 260.ms, duration: 350.ms),

          const SizedBox(height: 14),
          Center(
            child: Text('DermIQ · v1.0.0 (100)',
                style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
          ),
        ],
      ),
    );
  }
}
