import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _snack(BuildContext context, String msg) => AppSnackbar.show(context, msg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'About DermIQ'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Logo & version ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF2EDFF), Color(0xFFE8DEFF), Color(0xFFD8C8FF)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: context.dColors.cardShadow,
            ),
            child: Column(
              children: [
                const DiqLogo(size: DiqLogoSize.large),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.dColors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Version 1.0.0 (Build 100)',
                      style: AppTypography.caption.copyWith(
                          color: context.dColors.textPrimary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Text('© 2026 DermIQ Technologies',
                    style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04),

          const SizedBox(height: 20),

          // ── Mission ──────────────────────────────────────────────────────
          Container(
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
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary, size: 17),
                    ),
                    const SizedBox(width: 10),
                    Text('Our Mission', style: AppTypography.labelLarge),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'DermIQ empowers everyone to make smarter skincare and haircare decisions through AI-powered ingredient analysis and personalized routines — no dermatologist required.',
                  style: AppTypography.bodyMedium.copyWith(height: 1.6),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.03),

          const SizedBox(height: 16),

          // ── Stats ────────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _StatCard(value: '50K+', label: 'Users', icon: Icons.people_alt_rounded, color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(value: '1M+', label: 'Scans', icon: Icons.qr_code_scanner_rounded, color: const Color(0xFFEC4899))),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(value: '4.9★', label: 'Rating', icon: Icons.star_rounded, color: const Color(0xFFF59E0B))),
            ],
          ).animate().fadeIn(delay: 140.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // ── Follow us ────────────────────────────────────────────────────
          Text('Follow Us', style: AppTypography.labelLarge)
              .animate().fadeIn(delay: 180.ms, duration: 300.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SocialBtn(label: 'Instagram', icon: Icons.camera_alt_rounded, color: const Color(0xFFEC4899), onTap: () => _snack(context, 'Opening Instagram…'))),
              const SizedBox(width: 10),
              Expanded(child: _SocialBtn(label: 'X', icon: Icons.tag_rounded, color: context.dColors.textPrimary, onTap: () => _snack(context, 'Opening X…'))),
              const SizedBox(width: 10),
              Expanded(child: _SocialBtn(label: 'TikTok', icon: Icons.music_note_rounded, color: const Color(0xFF06B6D4), onTap: () => _snack(context, 'Opening TikTok…'))),
            ],
          ).animate().fadeIn(delay: 220.ms, duration: 300.ms),

          const SizedBox(height: 20),

          // ── Legal links ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.dColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: context.dColors.cardShadow,
            ),
            child: Column(
              children: [
                _LinkRow(icon: Icons.article_outlined, label: 'Terms of Service',
                    onTap: () => _snack(context, 'Opening Terms of Service…')),
                _LinkRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy',
                    onTap: () => context.push('/settings/privacy')),
                _LinkRow(icon: Icons.code_rounded, label: 'Open Source Licences',
                    onTap: () => showLicensePage(
                          context: context,
                          applicationName: 'DermIQ',
                          applicationVersion: '1.0.0',
                        )),
                _LinkRow(icon: Icons.help_outline_rounded, label: 'Help & Support',
                    onTap: () => context.push('/settings/help'), last: true),
              ],
            ),
          ).animate().fadeIn(delay: 260.ms, duration: 350.ms),

          const SizedBox(height: 20),
          Center(
            child: Text('Made with 💜 for healthy skin',
                style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
          ).animate().fadeIn(delay: 320.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ── _StatCard ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.labelLarge),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: context.dColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── _SocialBtn ────────────────────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: AppTypography.caption.copyWith(
                    color: context.dColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── _LinkRow ──────────────────────────────────────────────────────────────────

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool last;
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: context.dColors.surfaceDim,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: AppTypography.labelMedium)),
                Icon(Icons.chevron_right_rounded,
                    color: context.dColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.only(left: 66, right: 16),
            child: Divider(color: context.dColors.borderLight, height: 1),
          ),
      ],
    );
  }
}
