import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shelf_models.dart';
import '../../providers/shelf_provider.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class ShelfScreen extends ConsumerStatefulWidget {
  const ShelfScreen({super.key});

  @override
  ConsumerState<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends ConsumerState<ShelfScreen> {
  // Only ephemeral UI state stays local; products + filters live in shelfProvider.
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  ShelfNotifier get _notifier => ref.read(shelfProvider.notifier);

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);
    final products = shelf.filtered;
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(shelf),
            _buildTabBar(shelf),
            _buildCategoryChips(shelf),
            if (!_showSearch && shelf.tab == ShelfTab.all && shelf.categoryIndex == 0)
              _buildExpirySummaryBanner(shelf),
            Expanded(
              child: products.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: products.length,
                    itemBuilder: (context, i) => _ProductCard(
                      product: products[i],
                      onTap: () => context.push('/product/${products[i].id}'),
                    )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: i * 60), duration: 250.ms)
                    .slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOutCubic),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFABs(),
    );
  }

  Widget _buildHeader(ShelfState shelf) {
    return Container(
      color: context.dColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: _showSearch
              ? _SearchBar(
                  controller: _searchCtrl,
                  onChanged: _notifier.setQuery,
                  onClose: () {
                    _notifier.setQuery('');
                    _searchCtrl.clear();
                    setState(() => _showSearch = false);
                  },
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Shelf', style: AppTypography.h3),
                    Text(
                      '${shelf.products.length} products tracked',
                      style: AppTypography.caption.copyWith(color: context.dColors.textSecondary),
                    ),
                  ],
                ),
          ),
          if (!_showSearch) ...[
            _HeaderBtn(icon: Icons.search_rounded, onTap: () => setState(() => _showSearch = true)),
            _HeaderBtn(icon: Icons.tune_rounded, onTap: _openFilterSheet),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar(ShelfState shelf) {
    return Container(
      color: context.dColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          _TabChip(
            label: 'All',
            count: shelf.products.length,
            selected: shelf.tab == ShelfTab.all,
            onTap: () { _notifier.setTab(ShelfTab.all); _notifier.setCategory(0); },
          ),
          const SizedBox(width: 20),
          _TabChip(
            label: 'Favourites',
            count: shelf.favouritesCount,
            selected: shelf.tab == ShelfTab.favourites,
            onTap: () { _notifier.setTab(ShelfTab.favourites); _notifier.setCategory(0); },
          ),
          const SizedBox(width: 20),
          _TabChip(
            label: 'Expiring',
            count: shelf.expiringCount,
            selected: shelf.tab == ShelfTab.expiring,
            accent: shelf.expiringCount > 0,
            onTap: () { _notifier.setTab(ShelfTab.expiring); _notifier.setCategory(0); },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(ShelfState shelf) {
    return Container(
      color: context.dColors.surface,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(shelfCategories.length, (i) {
            final sel = shelf.categoryIndex == i;
            return Padding(
              padding: EdgeInsets.only(right: i < shelfCategories.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => _notifier.setCategory(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: sel ? AppColors.gradientPrimary : null,
                    color: sel ? null : context.dColors.surfaceDim,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    shelfCategories[i],
                    style: AppTypography.labelMedium.copyWith(
                      color: sel ? Colors.white : context.dColors.textSecondary,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildExpirySummaryBanner(ShelfState shelf) {
    final expired = shelf.products.where((p) => p.expiryStatus == ExpiryStatus.expired).toList();
    final expiring = shelf.products.where((p) => p.expiryStatus == ExpiryStatus.expiringSoon).toList();
    if (expired.isEmpty && expiring.isEmpty) return const SizedBox.shrink();

    final isExpired = expired.isNotEmpty;
    final bannerColor = isExpired ? AppColors.error : AppColors.warning;
    final count = isExpired ? expired.length : expiring.length;
    final label = isExpired
      ? '$count product${count > 1 ? 's' : ''} expired'
      : '$count product${count > 1 ? 's' : ''} expiring soon';

    return GestureDetector(
      onTap: () => _notifier.setTab(ShelfTab.expiring),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bannerColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bannerColor.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: bannerColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpired ? Icons.warning_amber_rounded : Icons.timer_outlined,
                color: bannerColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: bannerColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('Tap to review', style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.dColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: context.dColors.surfaceDim, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No products found', style: AppTypography.h4),
          const SizedBox(height: 6),
          Text(
            'Try a different filter or add a product',
            style: AppTypography.bodyMedium.copyWith(color: context.dColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'shelf_scan_fab',
          backgroundColor: context.dColors.surface,
          elevation: 4,
          onPressed: () => context.push('/scan'),
          child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'shelf_add_fab',
          backgroundColor: AppColors.primary,
          elevation: 6,
          onPressed: () => context.push('/shelf/add'),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: Text(
            'Add Product',
            style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ── _SearchBar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchBar({required this.controller, required this.onChanged, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(20)),
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: AppTypography.bodyMedium.copyWith(color: context.dColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: context.dColors.textTertiary),
                prefixIcon: Icon(Icons.search_rounded, size: 18, color: context.dColors.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onClose,
          child: Text('Cancel', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}

// ── _HeaderBtn ────────────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: context.dColors.textPrimary),
      ),
    );
  }
}

// ── _TabChip ──────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final bool accent;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: selected ? AppColors.primary : context.dColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: accent && !selected
                  ? AppColors.warning.withValues(alpha: 0.14)
                  : selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : context.dColors.surfaceDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTypography.caption.copyWith(
                  color: accent && !selected
                    ? AppColors.warning
                    : selected ? AppColors.primary : context.dColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _ProductCard ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ShelfProduct product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  Color get _scoreColor {
    if (product.score >= 85) return AppColors.success;
    if (product.score >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final status = product.expiryStatus;
    final daysLeft = product.daysLeft();
    final expiryColor = status == ExpiryStatus.expired
      ? AppColors.error
      : status == ExpiryStatus.expiringSoon
        ? AppColors.warning
        : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    product.color.withValues(alpha: 0.18),
                    product.color.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: product.color.withValues(alpha: 0.22), width: 1.2),
              ),
              child: Icon(Icons.spa_rounded, color: product.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTypography.labelLarge.copyWith(color: context.dColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.isFavourite) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.favorite_rounded, color: Color(0xFFEC4899), size: 15),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(product.brand, style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: _MiniTag(
                          text: product.category,
                          bg: context.dColors.surfaceDim,
                          fg: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _MiniTag(
                        text: '${product.score}',
                        bg: _scoreColor.withValues(alpha: 0.12),
                        fg: _scoreColor,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: expiryColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: expiryColor.withValues(alpha: 0.22), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status == ExpiryStatus.expired
                                ? Icons.warning_amber_rounded
                                : Icons.timer_outlined,
                              size: 11,
                              color: expiryColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              status == ExpiryStatus.expired ? 'Expired' : '${daysLeft}d left',
                              style: AppTypography.caption.copyWith(
                                color: expiryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: context.dColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── _MiniTag ──────────────────────────────────────────────────────────────────

class _MiniTag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _MiniTag({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── _FilterSheet ──────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  int _expiryIdx = 0;
  int _sortIdx = 0;

  static const _expiryOptions = ['All Status', 'Good', 'Expiring Soon', 'Expired'];
  static const _sortOptions = ['Name A–Z', 'Expiry (Soonest)', 'Safety Score', 'Date Added'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.elevatedShadow,
        ),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.dColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter & Sort', style: AppTypography.h4),
                GestureDetector(
                  onTap: () => setState(() { _expiryIdx = 0; _sortIdx = 0; }),
                  child: Text('Reset', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Expiry Status', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(_expiryOptions.length, (i) {
                final sel = _expiryIdx == i;
                return GestureDetector(
                  onTap: () => setState(() => _expiryIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: sel ? AppColors.gradientPrimary : null,
                      color: sel ? null : context.dColors.surfaceDim,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _expiryOptions[i],
                      style: AppTypography.labelMedium.copyWith(color: sel ? Colors.white : context.dColors.textSecondary),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text('Sort By', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(_sortOptions.length, (i) {
                final sel = _sortIdx == i;
                return GestureDetector(
                  onTap: () => setState(() => _sortIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: sel ? AppColors.gradientPrimary : null,
                      color: sel ? null : context.dColors.surfaceDim,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _sortOptions[i],
                      style: AppTypography.labelMedium.copyWith(color: sel ? Colors.white : context.dColors.textSecondary),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Apply Filters', style: AppTypography.button.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

