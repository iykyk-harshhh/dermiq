import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final current = themeAsync.valueOrNull ?? AppThemeMode.light;
    final c = context.dColors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 20, color: c.textPrimary),
          ),
        ),
        title: Text('Theme & Appearance', style: AppTypography.h4),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [

          // ── Section label ────────────────────────────────────────────────
          Text('Appearance', style: AppTypography.labelLarge)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 4),
          Text(
            'Choose how DermIQ looks on your device',
            style: AppTypography.caption.copyWith(color: c.textSecondary),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),

          // ── Theme mode cards ─────────────────────────────────────────────
          Row(
            children: AppThemeMode.values.map((mode) {
              final isSelected = mode == current;
              final idx = mode.index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx < 2 ? 10 : 0),
                  child: _ThemeModeCard(
                    mode: mode,
                    isSelected: isSelected,
                    onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
                    dColors: c,
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.04),

          const SizedBox(height: 28),

          // ── Live preview ─────────────────────────────────────────────────
          Text('Preview', style: AppTypography.labelLarge)
              .animate().fadeIn(delay: 160.ms, duration: 300.ms),
          const SizedBox(height: 14),
          _ThemePreview(dColors: c)
              .animate().fadeIn(delay: 200.ms, duration: 350.ms).slideY(begin: 0.04),

          const SizedBox(height: 28),

          // ── Fixed health colors note ──────────────────────────────────────
          Text('Health & Safety Colors', style: AppTypography.labelLarge)
              .animate().fadeIn(delay: 260.ms, duration: 300.ms),
          const SizedBox(height: 10),
          _HealthColorsCard(dColors: c)
              .animate().fadeIn(delay: 300.ms, duration: 350.ms).slideY(begin: 0.04),

          const SizedBox(height: 20),

          // ── Apply info ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surfaceDim,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Theme changes apply instantly and are saved automatically.',
                    style: AppTypography.caption.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 340.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThemeModeCard extends StatelessWidget {
  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final DermIQColors dColors;

  const _ThemeModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.dColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: dColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : dColors.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected ? AppColors.elevatedShadow : dColors.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini mockup preview
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: _previewGradient,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dColors.borderMedium),
              ),
              child: Icon(
                mode.icon,
                size: 20,
                color: mode == AppThemeMode.dark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              mode.label,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.primary : dColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : dColors.borderMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient get _previewGradient {
    switch (mode) {
      case AppThemeMode.light:
        return const LinearGradient(
          colors: [Color(0xFFF8F6FF), Color(0xFFEDE9FE)],
        );
      case AppThemeMode.dark:
        return const LinearGradient(
          colors: [Color(0xFF0F0D1A), Color(0xFF261F3D)],
        );
      case AppThemeMode.system:
        return const LinearGradient(
          colors: [Color(0xFF261F3D), Color(0xFFF0EDFF)],
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThemePreview extends StatelessWidget {
  final DermIQColors dColors;
  const _ThemePreview({required this.dColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: dColors.cardShadow,
        border: Border.all(color: dColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated header
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80, height: 10,
                    decoration: BoxDecoration(
                      color: dColors.textPrimary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 50, height: 8,
                    decoration: BoxDecoration(
                      color: dColors.textTertiary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: dColors.surfaceDim,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined,
                    size: 14, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simulated score card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.gradientHero,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70, height: 9,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40, height: 13,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Simulated nav bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: dColors.navBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavDot(icon: Icons.home_rounded, active: true, dColors: dColors),
                _NavDot(icon: Icons.auto_awesome_rounded, active: false, dColors: dColors),
                _NavDot(icon: Icons.camera_alt_rounded, active: false, dColors: dColors),
                _NavDot(icon: Icons.shopping_bag_rounded, active: false, dColors: dColors),
                _NavDot(icon: Icons.person_rounded, active: false, dColors: dColors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDot extends StatelessWidget {
  final IconData icon;
  final bool active;
  final DermIQColors dColors;
  const _NavDot({required this.icon, required this.active, required this.dColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: active
          ? BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Icon(icon, size: 14,
          color: active ? Colors.white : dColors.textTertiary),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HealthColorsCard extends StatelessWidget {
  final DermIQColors dColors;
  const _HealthColorsCard({required this.dColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'These colors never change — they always indicate ingredient safety.',
            style: AppTypography.caption.copyWith(color: dColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HealthChip(label: 'Safe', color: AppColors.success),
              _HealthChip(label: 'Caution', color: AppColors.warning),
              _HealthChip(label: 'Danger', color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  final String label;
  final Color color;
  const _HealthChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
