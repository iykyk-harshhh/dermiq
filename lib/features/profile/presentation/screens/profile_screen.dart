import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: AppTypography.h4),
        content: Text('You can sign back in anytime.', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: AppTypography.buttonSmall.copyWith(color: context.dColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out',
                style: AppTypography.buttonSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider).signOut();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final name = profile.name;
    final email = profile.email;
    final completion = profile.completionPercent;

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero header ────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.heroShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('My Profile',
                            style: AppTypography.labelLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.85))),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.settings_outlined,
                                color: Colors.white, size: 19),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B6FEA), Color(0xFFA78BFA)],
                                ),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                  style: AppTypography.h2.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0, bottom: 0,
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF3B2D9F), width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    size: 11, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: AppTypography.h4.copyWith(color: Colors.white)),
                              const SizedBox(height: 2),
                              Text(email,
                                  style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Completion bar
                    Row(
                      children: [
                        Text('Profile $completion% complete',
                            style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.75))),
                        const Spacer(),
                        if (completion < 100)
                          Text('Finish setup →',
                              style: AppTypography.caption.copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completion / 100,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04),

              const SizedBox(height: 20),

              // ── Skin Profile ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProfileCard(
                  icon: Icons.face_retouching_natural_rounded,
                  iconColor: AppColors.primary,
                  title: 'Skin Profile',
                  onEdit: () => context.push('/profile/edit-skin'),
                  rows: [
                    _Field('Skin Type', profile.skinType ?? 'Not set'),
                    _Field('Fitzpatrick', profile.fitzpatrick ?? 'Not set'),
                  ],
                  chipsLabel: 'Concerns',
                  chips: profile.skinConcerns,
                  chipColor: AppColors.primary,
                ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.04),
              ),

              const SizedBox(height: 14),

              // ── Hair Profile ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProfileCard(
                  icon: Icons.cut_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Hair Profile',
                  onEdit: () => context.push('/profile/edit-hair'),
                  rows: [
                    _Field('Hair Type', profile.hairType ?? 'Not set'),
                    _Field('Scalp Type', profile.scalpType ?? 'Not set'),
                  ],
                  chipsLabel: 'Concerns',
                  chips: profile.hairConcerns,
                  chipColor: const Color(0xFFEC4899),
                ).animate().fadeIn(delay: 140.ms, duration: 350.ms).slideY(begin: 0.04),
              ),

              const SizedBox(height: 20),

              // ── Menu ───────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.shopping_bag_rounded,
                      label: 'My Orders',
                      subtitle: 'Track and view order history',
                      onTap: () => context.push('/orders'),
                    ),
                    _MenuTile(
                      icon: Icons.inventory_2_rounded,
                      label: 'My Shelf',
                      subtitle: 'Personal product tracker',
                      onTap: () => context.push('/my-shelf'),
                    ),
                    _MenuTile(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Gifts & Rewards',
                      subtitle: 'Your streak reward collection',
                      onTap: () => context.push('/profile/gifts'),
                    ),
                    _MenuTile(
                      icon: Icons.tune_rounded,
                      label: 'Preferences',
                      subtitle: 'Reminders, units & regional',
                      onTap: () => context.push('/profile/preferences'),
                    ),
                    _MenuTile(
                      icon: Icons.trending_up_rounded,
                      label: 'My Progress',
                      subtitle: 'Skin score trends over time',
                      onTap: () => context.push('/progress'),
                    ),
                    _MenuTile(
                      icon: Icons.event_note_rounded,
                      label: 'My Appointments',
                      subtitle: 'Upcoming & past consultations',
                      onTap: () => context.push('/appointments'),
                    ),
                    _MenuTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'My Shelf',
                      subtitle: 'Saved products & expiry',
                      onTap: () => context.go('/shelf'),
                    ),
                    _MenuTile(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      subtitle: 'Theme, notifications & privacy',
                      onTap: () => context.push('/settings'),
                    ),
                    _MenuTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      subtitle: 'FAQs and contact',
                      onTap: () => context.push('/settings/help'),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
              ),

              const SizedBox(height: 18),

              // ── Sign out ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
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
                        const Icon(Icons.logout_rounded,
                            color: AppColors.error, size: 19),
                        const SizedBox(width: 8),
                        Text('Sign Out',
                            style: AppTypography.button.copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text('DermIQ · v1.0.0',
                    style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _Field ────────────────────────────────────────────────────────────────────

class _Field {
  final String label, value;
  const _Field(this.label, this.value);
}

// ── _ProfileCard ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onEdit;
  final List<_Field> rows;
  final String chipsLabel;
  final List<String> chips;
  final Color chipColor;

  const _ProfileCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onEdit,
    required this.rows,
    required this.chipsLabel,
    required this.chips,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTypography.labelLarge),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 12, color: iconColor),
                      const SizedBox(width: 4),
                      Text('Edit',
                          style: AppTypography.caption.copyWith(
                              color: iconColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: rows
                .map((r) => Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.label,
                              style: AppTypography.caption.copyWith(
                                  color: context.dColors.textTertiary)),
                          const SizedBox(height: 2),
                          Text(r.value, style: AppTypography.labelMedium),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(chipsLabel,
              style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
          const SizedBox(height: 8),
          if (chips.isEmpty)
            Text('None added yet',
                style: AppTypography.bodySmall.copyWith(color: context.dColors.textTertiary))
          else
            Wrap(
              spacing: 8, runSpacing: 8,
              children: chips
                  .map((c) => Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: chipColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(c,
                            style: AppTypography.labelSmall.copyWith(color: chipColor)),
                      ))
                  .toList(),
            ),
        ],
      ),
      ),
    );
  }
}

// ── _MenuTile ─────────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: context.dColors.surfaceDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                          color: context.dColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: context.dColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
