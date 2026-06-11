import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../providers/scan_provider.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

class _P {
  final String name, brand, category;
  final int    score;
  final Color  color;
  const _P(this.name, this.brand, this.category, this.score, this.color);
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ManualSearchScreen extends ConsumerStatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  ConsumerState<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends ConsumerState<ManualSearchScreen> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();

  // Search query + category filter live in scanProvider.
  static const _filters = scanCategories;

  static const _recents = ['CeraVe', 'Niacinamide', 'SPF 50', 'Retinol Serum'];

  static const _products = [
    _P('CeraVe Foaming Facial Cleanser', 'CeraVe', 'Cleanser', 92, Color(0xFF0EA5E9)),
    _P('The Ordinary Niacinamide 10% + Zinc', 'The Ordinary', 'Serum', 86, Color(0xFF8B5CF6)),
    _P('Neutrogena Ultra Dry-Touch SPF 55', 'Neutrogena', 'Sunscreen', 78, Color(0xFFF59E0B)),
    _P('La Roche-Posay Toleriane Moisturizer', 'La Roche-Posay', 'Moisturizer', 90, Color(0xFF22C55E)),
    _P('Cetaphil Gentle Skin Cleanser', 'Cetaphil', 'Cleanser', 87, Color(0xFF06B6D4)),
    _P("Paula's Choice 2% BHA Exfoliant", "Paula's Choice", 'Treatment', 82, Color(0xFFF43F5E)),
    _P('Estée Lauder Advanced Night Repair', 'Estée Lauder', 'Serum', 88, Color(0xFF7C5CFF)),
    _P('Clinique Moisture Surge 100H', 'Clinique', 'Moisturizer', 85, Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  ScanNotifier get _notifier => ref.read(scanProvider.notifier);

  List<_P> _filteredFor(ScanState scan) {
    var list = _products.toList();
    if (scan.categoryIndex != 0) {
      list = list.where((p) => p.category == _filters[scan.categoryIndex]).toList();
    }
    if (scan.query.isNotEmpty) {
      final q = scan.query.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final scan      = ref.watch(scanProvider);
    final items     = _filteredFor(scan);
    final showEmpty = scan.query.isNotEmpty && items.isEmpty;

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky header ────────────────────────────────────────────
            Container(
              color: context.dColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.dColors.surfaceDim,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: context.dColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _ctrl,
                            focusNode: _focus,
                            hintText: 'Search product or ingredient…',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            suffixIcon: scan.query.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _ctrl.clear();
                                      _notifier.setQuery('');
                                    },
                                    child: Icon(
                                      Icons.clear_rounded,
                                      color: context.dColors.textTertiary,
                                      size: 18,
                                    ),
                                  )
                                : null,
                            onChanged: _notifier.setQuery,
                            onSubmitted: (v) {
                              if (v.trim().isNotEmpty) _notifier.recordScan(v.trim());
                              context.push('/scan/results');
                            },
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter chips row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: Row(
                      children: List.generate(_filters.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(
                              right: i < _filters.length - 1 ? 8 : 0),
                          child: _FilterChip(
                            label:    _filters[i],
                            selected: scan.categoryIndex == i,
                            onTap:    () => _notifier.setCategory(i),
                          ),
                        );
                      }),
                    ),
                  ),

                  const Divider(color: Color(0xFFF0EDFF), height: 1),
                ],
              ),
            ),

            // ── Results list ─────────────────────────────────────────────
            Expanded(
              child: showEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      itemCount: items.length + 1,
                      itemBuilder: (_, i) => scan.query.isEmpty
                          ? _buildBrowseContent(items, i)
                          : _buildSearchContent(items, i),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Section rendered when no query — shows recent + popular
  Widget _buildBrowseContent(List<_P> items, int i) {
    if (i == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Recent Searches'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recents
                .map((r) => _RecentChip(
                      label: r,
                      onTap: () => context.push('/scan/results'),
                    ))
                .toList(),
          ),
          const SizedBox(height: 22),
          _SectionLabel('Popular Products', count: items.length),
          const SizedBox(height: 12),
        ],
      );
    }
    final idx = i - 1;
    if (idx >= items.length) return const SizedBox.shrink();
    return _ProductItem(
      product: items[idx],
      index:   idx,
      onTap:   () => context.push('/scan/analysis/p${idx + 1}'),
    );
  }

  // Section rendered when query is active
  Widget _buildSearchContent(List<_P> items, int i) {
    if (i == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SectionLabel(
          '${items.length} result${items.length == 1 ? '' : 's'} for "${ref.read(scanProvider).query}"',
        ),
      );
    }
    final idx = i - 1;
    if (idx >= items.length) return const SizedBox.shrink();
    return _ProductItem(
      product: items[idx],
      index:   idx,
      onTap:   () => context.push('/scan/analysis/p${idx + 1}'),
    );
  }
}

// ─── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String     label;
  final bool       selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradientPrimary : null,
          color:    selected ? null : context.dColors.surfaceDim,
          borderRadius: BorderRadius.circular(20),
          border:   selected
              ? null
              : Border.all(color: context.dColors.borderLight),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? Colors.white : context.dColors.textSecondary,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final int?   count;

  const _SectionLabel(this.title, {this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            color:      context.dColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color:        AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: AppTypography.caption.copyWith(
                color:      AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize:   10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Recent chip ──────────────────────────────────────────────────────────────

class _RecentChip extends StatelessWidget {
  final String     label;
  final VoidCallback onTap;

  const _RecentChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:        context.dColors.surface,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: const Color(0xFFE8DEFF)),
          boxShadow:    context.dColors.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded,
                size: 12, color: context.dColors.textTertiary),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color:      context.dColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product item ─────────────────────────────────────────────────────────────

class _ProductItem extends StatelessWidget {
  final _P         product;
  final int        index;
  final VoidCallback onTap;

  const _ProductItem({
    required this.product,
    required this.index,
    required this.onTap,
  });

  Color get _scoreColor {
    if (product.score >= 80) return const Color(0xFF22C55E);
    if (product.score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        context.dColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow:    context.dColors.cardShadow,
          border:       Border.all(color: const Color(0xFFF0EDFF)),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [
                    product.color.withValues(alpha: 0.20),
                    product.color.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                    color: product.color.withValues(alpha: 0.18)),
              ),
              child: Icon(Icons.spa_rounded,
                  color: product.color, size: 24),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTypography.labelMedium
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: AppTypography.caption
                        .copyWith(color: context.dColors.textTertiary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _CategoryBadge(product.category),
                      const SizedBox(width: 6),
                      _ScorePill(
                          score: product.score, color: _scoreColor),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: context.dColors.textTertiary),
          ],
        ),
      )
          .animate()
          .fadeIn(
            duration: 280.ms,
            delay: Duration(milliseconds: 36 * index),
          )
          .slideX(
            begin: 0.04,
            duration: 280.ms,
            delay: Duration(milliseconds: 36 * index),
            curve: Curves.easeOut,
          ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color:      AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize:   10,
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int   score;
  final Color color;
  const _ScorePill({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            '$score',
            style: AppTypography.caption.copyWith(
              color:      color,
              fontWeight: FontWeight.w700,
              fontSize:   10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color:  context.dColors.surfaceDim,
              shape:  BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size:  34,
              color: context.dColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: AppTypography.labelLarge
                .copyWith(color: context.dColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different name or brand',
            style: AppTypography.caption
                .copyWith(color: context.dColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
