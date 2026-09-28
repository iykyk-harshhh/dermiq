import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dermiq/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l.signOutConfirmTitle,
      message: l.signOutConfirmMessage,
      confirmLabel: l.signOut,
      danger: true,
    );
    if (confirmed != true) return;
    // Clear the session. The router's auth guard (wired to authState via
    // refreshListenable) then redirects this protected screen to /login on its
    // own — exactly once. We deliberately DON'T also call context.go('/login')
    // here: doing both raced two navigations to /login and left a black frame.
    await ref.read(authProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final name = user?.displayName ?? 'Guest';
    final email = user?.email ?? '';
    final l = AppLocalizations.of(context);
    // Derive the theme row value from the real current theme so it reflects the
    // active mode and updates live when changed. Falls back to Light while the
    // async theme is still loading.
    final themeMode = ref.watch(themeProvider).valueOrNull ?? AppThemeMode.light;

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppTopBar(title: l.settings),
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
          AppSectionCard(title: l.sectionAccount, children: [
            AppSettingsTile(
              icon: Icons.manage_accounts_rounded, iconColor: AppColors.primary,
              label: l.editProfile, onTap: () => context.push('/profile/edit'),
            ),
            AppSettingsTile(
              icon: Icons.face_retouching_natural_rounded, iconColor: AppColors.primary,
              label: l.skinProfile, onTap: () => context.push('/profile/edit-skin'),
            ),
            AppSettingsTile(
              icon: Icons.cut_rounded, iconColor: const Color(0xFFEC4899),
              label: l.hairProfile, onTap: () => context.push('/profile/edit-hair'),
            ),
            AppSettingsTile(
              icon: Icons.tune_rounded, iconColor: const Color(0xFF06B6D4),
              label: l.preferences, onTap: () => context.push('/profile/preferences'),
            ),
            AppSettingsTile(
              icon: Icons.event_note_rounded, iconColor: const Color(0xFF8B5CF6),
              label: l.myAppointments, onTap: () => context.push('/appointments'),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── App ──────────────────────────────────────────────────────────
          AppSectionCard(title: l.sectionApp, children: [
            AppSettingsTile(
              icon: Icons.palette_outlined, iconColor: const Color(0xFFF59E0B),
              label: l.themeAndAppearance, value: themeMode.label,
              onTap: () => context.push('/settings/theme'),
            ),
            AppSettingsTile(
              icon: Icons.notifications_none_rounded, iconColor: AppColors.primary,
              label: l.notifications, onTap: () => context.push('/settings/notifications'),
            ),
            AppSettingsTile(
              icon: Icons.lock_outline_rounded, iconColor: AppColors.success,
              label: l.privacyAndData, onTap: () => context.push('/settings/privacy'),
              divider: false,
            ),
          ]).animate().fadeIn(delay: 140.ms, duration: 350.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── Support ──────────────────────────────────────────────────────
          AppSectionCard(title: l.sectionSupport, children: [
            AppSettingsTile(
              icon: Icons.help_outline_rounded, iconColor: const Color(0xFF0EA5E9),
              label: l.helpAndSupport, onTap: () => context.push('/settings/help'),
            ),
            AppSettingsTile(
              icon: Icons.info_outline_rounded, iconColor: AppColors.primary,
              label: l.aboutDermIQ, divider: false,
              onTap: () => context.push('/settings/about'),
            ),
            // "Rate the App" removed until the app is live on the store.
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
                  Text(l.signOut,
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
