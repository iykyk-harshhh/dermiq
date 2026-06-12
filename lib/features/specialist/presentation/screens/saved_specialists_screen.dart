import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/specialist_models.dart';
import '../../providers/saved_specialist_provider.dart';

class SavedSpecialistsScreen extends ConsumerWidget {
  const SavedSpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedSpecialistProvider);
    final saved =
        specialistMocks.where((s) => savedIds.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('Saved Specialists', style: AppTypography.h4),
        centerTitle: true,
      ),
      body: saved.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              itemCount: saved.length,
              itemBuilder: (_, i) {
                final s = saved[i];
                return _SavedCard(
                  specialist: s,
                  onTap: () => context.push('/specialist/${s.id}'),
                  onRemove: () =>
                      ref.read(savedSpecialistProvider.notifier).toggle(s.id),
                ).animate().fadeIn(duration: 300.ms, delay: (i * 60).ms).slideY(begin: 0.06);
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 56, color: context.dColors.textTertiary),
          const SizedBox(height: 12),
          Text('No saved specialists',
              style: AppTypography.labelLarge
                  .copyWith(color: context.dColors.textTertiary)),
          const SizedBox(height: 6),
          Text('Tap the bookmark on a specialist to save them here',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(color: context.dColors.textTertiary)),
        ],
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final Specialist specialist;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _SavedCard({
    required this.specialist,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final s = specialist;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [s.color, s.color.withValues(alpha: 0.7)]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(s.initials,
                    style: AppTypography.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: AppTypography.labelLarge,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${s.type} · ${s.hospital}',
                      style: AppTypography.caption
                          .copyWith(color: context.dColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFD4A017), size: 13),
                      const SizedBox(width: 3),
                      Text('${s.rating} · ${s.reviews} reviews',
                          style: AppTypography.caption
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.bookmark_rounded,
                  color: AppColors.primary, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
