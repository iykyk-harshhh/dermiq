import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../streak/data/streak_models.dart';
import '../../../streak/providers/streak_provider.dart';

class GiftsScreen extends ConsumerWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('My Gifts', style: AppTypography.h4),
        centerTitle: true,
      ),
      body: streakAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (streak) {
          final rewards = streak.rewards;
          final active = rewards.where((r) => r.status == RewardStatus.active).toList();
          final redeemed = rewards.where((r) => r.status == RewardStatus.redeemed).toList();
          final expired = rewards.where((r) => r.status == RewardStatus.expired).toList();

          if (rewards.isEmpty) {
            return _EmptyState();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              // Summary
              _SummaryBar(active: active.length, redeemed: redeemed.length, expired: expired.length)
                  .animate().fadeIn(duration: 350.ms).slideY(begin: 0.06),
              const SizedBox(height: 20),

              if (active.isNotEmpty) ...[
                _SectionLabel(label: 'Active', count: active.length, color: AppColors.success),
                const SizedBox(height: 10),
                ...active.asMap().entries.map(
                  (e) => _GiftCard(
                    gift: e.value,
                    onRedeem: () => ref.read(streakProvider.notifier).redeemReward(e.value.id),
                  ).animate().fadeIn(duration: 350.ms, delay: (e.key * 60).ms).slideY(begin: 0.05),
                ),
                const SizedBox(height: 20),
              ],

              if (redeemed.isNotEmpty) ...[
                _SectionLabel(label: 'Redeemed', count: redeemed.length, color: AppColors.primary),
                const SizedBox(height: 10),
                ...redeemed.asMap().entries.map(
                  (e) => _GiftCard(gift: e.value)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (e.key * 50).ms),
                ),
                const SizedBox(height: 20),
              ],

              if (expired.isNotEmpty) ...[
                _SectionLabel(label: 'Expired', count: expired.length, color: context.dColors.textTertiary),
                const SizedBox(height: 10),
                ...expired.asMap().entries.map(
                  (e) => _GiftCard(gift: e.value)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (e.key * 50).ms),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int active, redeemed, expired;
  const _SummaryBar({required this.active, required this.redeemed, required this.expired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.heroShadow,
      ),
      child: Row(
        children: [
          Expanded(child: _StatCell(value: '$active', label: 'Active', icon: '🎁')),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.18)),
          Expanded(child: _StatCell(value: '$redeemed', label: 'Redeemed', icon: '✅')),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.18)),
          Expanded(child: _StatCell(value: '$expired', label: 'Expired', icon: '⏰')),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label, icon;
  const _StatCell({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTypography.metricSmall.copyWith(color: Colors.white, fontSize: 22)),
        Text(label,
            style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.65), fontSize: 10)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SectionLabel({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: AppTypography.caption.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GiftCard extends StatelessWidget {
  final RewardGift gift;
  final VoidCallback? onRedeem;
  const _GiftCard({required this.gift, this.onRedeem});

  Color _statusColor(BuildContext context) {
    switch (gift.status) {
      case RewardStatus.active:   return AppColors.success;
      case RewardStatus.redeemed: return AppColors.primary;
      case RewardStatus.expired:  return context.dColors.textTertiary;
    }
  }

  String get _statusLabel {
    switch (gift.status) {
      case RewardStatus.active:   return 'ACTIVE';
      case RewardStatus.redeemed: return 'REDEEMED';
      case RewardStatus.expired:  return 'EXPIRED';
    }
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(
          color: gift.status == RewardStatus.active
              ? AppColors.success.withValues(alpha: 0.25)
              : context.dColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gift.name,
                        style: AppTypography.labelMedium.copyWith(
                          color: gift.status == RewardStatus.expired
                              ? context.dColors.textTertiary
                              : context.dColors.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(gift.type,
                        style: AppTypography.caption.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_statusLabel,
                    style: AppTypography.caption.copyWith(
                        color: color, fontWeight: FontWeight.w700, fontSize: 10,
                        letterSpacing: 0.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: context.dColors.borderLight),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateChip(
                    icon: Icons.celebration_rounded,
                    label: 'Claimed',
                    date: _fmt(gift.claimedDate)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateChip(
                    icon: Icons.schedule_rounded,
                    label: 'Expires',
                    date: _fmt(gift.expiryDate)),
              ),
            ],
          ),
          if (gift.status == RewardStatus.active && onRedeem != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRedeem,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('Redeem Now',
                      style: AppTypography.buttonSmall.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label, date;
  const _DateChip({required this.icon, required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.dColors.textTertiary),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                      color: context.dColors.textTertiary, fontSize: 9.5)),
              Text(date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                      color: context.dColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎁', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 16),
            Text('No rewards yet', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Text(
              'Keep your streak going to unlock rewards at\n7, 30, 50, 100, 150, 200 and 365 days.',
              style: AppTypography.bodySmall.copyWith(
                  color: context.dColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
