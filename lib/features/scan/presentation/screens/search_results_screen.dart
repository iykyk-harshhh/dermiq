import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

class _R {
  final String name, brand, category, desc;
  final int    safety, skinScore, hairScore;
  final Color  color;
  final bool   hasFlag;
  const _R(this.name, this.brand, this.category, this.desc,
      this.safety, this.skinScore, this.hairScore, this.color,
      this.hasFlag);
}

enum _Sort { bestMatch, highestRated, az }

// ─── Screen ──────────────────────────────────────────────────────────────────

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  _Sort _sort      = _Sort.bestMatch;
  int   _filterIdx = 0;

  static const _catFilters = [
    'All', 'Cleanser', 'Moisturizer', 'Serum', 'Sunscreen', 'Treatment',
  ];

  static const _all = [
    _R(
      'CeraVe Foaming Facial Cleanser',
      'CeraVe',
      'Cleanser',
      'Non-comedogenic cleanser with ceramides, hyaluronic acid and niacinamide.',
      92, 88, 82,
      Color(0xFF0EA5E9),
      false,
    ),
    _R(
      'CeraVe Moisturising Cream',
      'CeraVe',
      'Moisturizer',
      'Rich 24-hour cream with 3 essential ceramides and patented MVE technology.',
      88, 85, 79,
      Color(0xFF22C55E),
      false,
    ),
    _R(
      'CeraVe AM Facial Moisturising Lotion',
      'CeraVe',
      'Moisturizer',
      'Lightweight SPF 30 moisturiser with ceramides for daily UV protection.',
      79, 76, 64,
      Color(0xFFF59E0B),
      true,
    ),
    _R(
      'CeraVe Hydrating Toner',
      'CeraVe',
      'Treatment',
      'Alcohol-free toner that restores the skin\'s natural pH with hyaluronic acid.',
      85, 83, 71,
      Color(0xFF8B5CF6),
      false,
    ),
    _R(
      'CeraVe Eye Repair Cream',
      'CeraVe',
      'Treatment',
      'Fragrance-free eye cream that reduces dark circles and puffiness.',
      82, 80, 68,
      Color(0xFF06B6D4),
      false,
    ),
  ];

  List<_R> get _results {
    var list = _all.toList();

    if (_filterIdx != 0) {
      list = list
          .where((r) => r.category == _catFilters[_filterIdx])
          .toList();
    }

    switch (_sort) {
      case _Sort.bestMatch:
        list.sort((a, b) {
          final aAvg = (a.safety + a.skinScore + a.hairScore) / 3;
          final bAvg = (b.safety + b.skinScore + b.hairScore) / 3;
          return bAvg.compareTo(aAvg);
        });
      case _Sort.highestRated:
        list.sort((a, b) => b.safety.compareTo(a.safety));
      case _Sort.az:
        list.sort((a, b) => a.name.compareTo(b.name));
    }

    return list;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SortSheet(
        current:  _sort,
        onSelect: (s) {
          setState(() => _sort = s);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _results;

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Pinned header ─────────────────────────────────────────────
            Container(
              color: context.dColors.surface,
              child: Column(
                children: [
                  // Title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:  context.dColors.surfaceDim,
                              shape:  BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size:  20,
                              color: context.dColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Search Results', style: AppTypography.h4),
                              Text(
                                '${items.length} product${items.length == 1 ? '' : 's'} found',
                                style: AppTypography.caption
                                    .copyWith(color: context.dColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        // Sort button
                        GestureDetector(
                          onTap: _showSortSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color:        context.dColors.surfaceDim,
                              borderRadius: BorderRadius.circular(20),
                              border:       Border.all(
                                  color: context.dColors.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sort_rounded,
                                    size:  15,
                                    color: AppColors.primary),
                                const SizedBox(width: 5),
                                Text(
                                  _sortLabel(_sort),
                                  style: AppTypography.caption.copyWith(
                                    color:      AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: List.generate(_catFilters.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(
                              right: i < _catFilters.length - 1 ? 8 : 0),
                          child: _FilterChip(
                            label:    _catFilters[i],
                            selected: _filterIdx == i,
                            onTap:    () => setState(() => _filterIdx = i),
                          ),
                        );
                      }),
                    ),
                  ),

                  const Divider(color: Color(0xFFF0EDFF), height: 1),
                ],
              ),
            ),

            // ── Product cards ─────────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _EmptyFilter(onClear: () => setState(() => _filterIdx = 0))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _ProductCard(
                        result: items[i],
                        index:  i,
                        onTap:  () =>
                            context.push('/scan/analysis/p${i + 1}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _sortLabel(_Sort s) => switch (s) {
        _Sort.bestMatch    => 'Best Match',
        _Sort.highestRated => 'Highest Rated',
        _Sort.az           => 'A–Z',
      };
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient:     selected ? AppColors.gradientPrimary : null,
          color:        selected ? null : context.dColors.surfaceDim,
          borderRadius: BorderRadius.circular(20),
          border:       selected
              ? null
              : Border.all(color: context.dColors.borderLight),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color:      selected ? Colors.white : context.dColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Product card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final _R         result;
  final int        index;
  final VoidCallback onTap;

  const _ProductCard({
    required this.result,
    required this.index,
    required this.onTap,
  });

  static Color _scoreColor(int s) {
    if (s >= 85) return const Color(0xFF22C55E);
    if (s >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  static String _matchLabel(int s) {
    if (s >= 85) return 'Excellent';
    if (s >= 70) return 'Good';
    return 'Fair';
  }

  static Color _matchColor(int s) {
    if (s >= 85) return const Color(0xFF22C55E);
    if (s >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFF97316);
  }

  @override
  Widget build(BuildContext context) {
    final avg      = (result.safety + result.skinScore + result.hairScore) ~/ 3;
    final matchCol = _matchColor(avg);

    return Container(
      margin:     const EdgeInsets.only(bottom: 14),
      padding:    const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow:    context.dColors.cardShadow,
        border:       Border.all(color: const Color(0xFFF0EDFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top info ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                    colors: [
                      result.color.withValues(alpha: 0.22),
                      result.color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border:       Border.all(
                      color: result.color.withValues(alpha: 0.18)),
                ),
                child: Icon(Icons.spa_rounded,
                    color: result.color, size: 36),
              ),

              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            result.name,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Match badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:        matchCol.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                            border:       Border.all(
                                color: matchCol.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            _matchLabel(avg),
                            style: AppTypography.caption.copyWith(
                              color:      matchCol,
                              fontWeight: FontWeight.w700,
                              fontSize:   10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.brand,
                      style: AppTypography.caption
                          .copyWith(color: context.dColors.textTertiary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.desc,
                      style: AppTypography.caption.copyWith(
                        color:  context.dColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _CatBadge(result.category),
                        if (result.hasFlag) ...[
                          const SizedBox(width: 6),
                          _FlagPill(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF0EDFF), height: 1),
          const SizedBox(height: 14),

          // ── Score row ─────────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _ScoreItem(
                    label: 'Safety',
                    score: result.safety,
                    color: _scoreColor(result.safety),
                  ),
                ),
                VerticalDivider(
                    color: const Color(0xFFF0EDFF),
                    width: 1,
                    thickness: 1),
                Expanded(
                  child: _ScoreItem(
                    label: 'Skin Match',
                    score: result.skinScore,
                    color: _scoreColor(result.skinScore),
                  ),
                ),
                VerticalDivider(
                    color: const Color(0xFFF0EDFF),
                    width: 1,
                    thickness: 1),
                Expanded(
                  child: _ScoreItem(
                    label: 'Hair Match',
                    score: result.hairScore,
                    color: _scoreColor(result.hairScore),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Actions ───────────────────────────────────────────────────
          Row(
            children: [
              // Save button
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color:        context.dColors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: context.dColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_border_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(
                      'Save',
                      style: AppTypography.labelSmall.copyWith(
                        color:      AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Analysis button
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient:     AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics_rounded,
                            size: 15, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Full Analysis',
                          style: AppTypography.labelSmall.copyWith(
                            color:      Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: 360.ms,
          delay:    Duration(milliseconds: 70 * index),
        )
        .slideY(
          begin:    0.08,
          duration: 360.ms,
          delay:    Duration(milliseconds: 70 * index),
          curve:    Curves.easeOutCubic,
        );
  }
}

// ─── Score item ───────────────────────────────────────────────────────────────

class _ScoreItem extends StatelessWidget {
  final String label;
  final int    score;
  final Color  color;

  const _ScoreItem({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            '$score',
            style: AppTypography.metricSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          // Score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: Align(
                alignment:   Alignment.centerLeft,
                widthFactor: score / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    color:        color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
                color: context.dColors.textTertiary, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Small badge widgets ──────────────────────────────────────────────────────

class _CatBadge extends StatelessWidget {
  final String label;
  const _CatBadge(this.label);

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

class _FlagPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 10, color: Color(0xFFEF4444)),
          const SizedBox(width: 3),
          Text(
            'Flagged',
            style: AppTypography.caption.copyWith(
              color:      const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
              fontSize:   10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sort bottom sheet ────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final _Sort      current;
  final void Function(_Sort) onSelect;

  const _SortSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        context.dColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color:        context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Sort By', style: AppTypography.h4),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color:  context.dColors.surfaceDim,
                    shape:  BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: context.dColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            (_Sort.bestMatch,    'Best Match',    Icons.auto_awesome_rounded),
            (_Sort.highestRated, 'Highest Rated', Icons.star_rounded),
            (_Sort.az,           'A – Z',         Icons.sort_by_alpha_rounded),
          ].map((entry) {
            final (sort, label, icon) = entry;
            final isSelected = current == sort;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSelect(sort),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color:        isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : context.dColors.surfaceDim,
                    borderRadius: BorderRadius.circular(14),
                    border:       isSelected
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.22))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          size:  18,
                          color: isSelected
                              ? AppColors.primary
                              : context.dColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : context.dColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Empty filter state ───────────────────────────────────────────────────────

class _EmptyFilter extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyFilter({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color:  context.dColors.surfaceDim,
              shape:  BoxShape.circle,
            ),
            child: Icon(Icons.filter_list_off_rounded,
                size: 34, color: context.dColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text('No results in this category',
              style: AppTypography.labelLarge),
          const SizedBox(height: 6),
          Text('Try a different filter',
              style: AppTypography.caption
                  .copyWith(color: context.dColors.textTertiary)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient:     AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Show All',
                style: AppTypography.labelSmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
