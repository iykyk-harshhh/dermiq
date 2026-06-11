import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/specialist_models.dart';

class SpecialistDetailScreen extends StatelessWidget {
  final String id;
  const SpecialistDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final s = lookupSpecialist(id);

    return Scaffold(
      backgroundColor: context.dColors.background,
      bottomNavigationBar: _BookBar(
        fee: s.fee,
        onBook: () => context.push('/specialist/$id/book'),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Hero ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1E1B4B),
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1E1B4B), s.color],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 92, height: 92,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [s.color, s.color.withValues(alpha: 0.7)]),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25), width: 2),
                        ),
                        child: Center(
                            child: Text(s.initials,
                                style: AppTypography.h2.copyWith(color: Colors.white))),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(s.name,
                            style: AppTypography.h3.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('${s.type} · ${s.qualifications}',
                            style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.7)),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _StatChip('${s.rating} ★', const Color(0xFFFFD700)),
                            _StatChip('${s.reviews} reviews', Colors.white),
                            _StatChip('${s.yearsExp} yrs exp', Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats row
                Row(
                  children: [
                    Expanded(child: _QuickStat(
                        icon: Icons.star_rounded, value: '${s.rating}',
                        label: 'Rating', color: const Color(0xFFF59E0B))),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickStat(
                        icon: Icons.people_alt_rounded, value: '${s.reviews}',
                        label: 'Patients', color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickStat(
                        icon: Icons.workspace_premium_rounded, value: '${s.yearsExp}y',
                        label: 'Experience', color: AppColors.success)),
                  ],
                ).animate().fadeIn(duration: 350.ms),

                const SizedBox(height: 16),

                _SectionCard(
                  title: 'About',
                  child: Text(s.about,
                      style: AppTypography.bodyMedium.copyWith(height: 1.6)),
                ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Specialties',
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: s.specialties
                        .map((sp) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: s.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(sp,
                                  style: AppTypography.labelSmall
                                      .copyWith(color: s.color)),
                            ))
                        .toList(),
                  ),
                ).animate().fadeIn(delay: 140.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Available Today',
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: s.slots
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: context.dColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.dColors.borderMedium),
                              ),
                              child: Text(t, style: AppTypography.labelSmall),
                            ))
                        .toList(),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 16),

                // Reviews preview
                _SectionCard(
                  title: 'Patient Reviews',
                  child: Column(
                    children: const [
                      _Review('Emma R.', 5,
                          'Incredibly thorough and kind. My skin has never looked better!'),
                      Divider(height: 24),
                      _Review('David L.', 5,
                          'Clear explanations and a treatment plan that actually worked.'),
                    ],
                  ),
                ).animate().fadeIn(delay: 260.ms, duration: 350.ms).slideY(begin: 0.04),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _BookBar ──────────────────────────────────────────────────────────────────

class _BookBar extends StatelessWidget {
  final double fee;
  final VoidCallback onBook;
  const _BookBar({required this.fee, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Consultation',
                  style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
              Text('\$${fee.toStringAsFixed(0)}',
                  style: AppTypography.metricSmall),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onBook,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Book Appointment',
                        style: AppTypography.button.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _StatChip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: AppTypography.labelSmall.copyWith(
              color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── _QuickStat ────────────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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

// ── _SectionCard ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── _Review ───────────────────────────────────────────────────────────────────

class _Review extends StatelessWidget {
  final String name;
  final int stars;
  final String text;
  const _Review(this.name, this.stars, this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(name, style: AppTypography.labelMedium),
            const Spacer(),
            Row(
              children: List.generate(
                  stars,
                  (_) => const Icon(Icons.star_rounded,
                      color: Color(0xFFF59E0B), size: 14)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(text,
            style: AppTypography.bodySmall.copyWith(height: 1.5)),
      ],
    );
  }
}
