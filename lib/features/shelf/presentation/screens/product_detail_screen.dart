import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shelf_models.dart';
import '../../providers/shelf_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterAnim;

  ShelfProduct? get _product => ref.read(shelfProvider.notifier).byId(widget.productId);

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _enterAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove Product?', style: AppTypography.h4),
        content: Text(
          'This product will be removed from your shelf.',
          style: AppTypography.bodyMedium.copyWith(color: context.dColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.labelMedium.copyWith(color: context.dColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(shelfProvider.notifier).removeProduct(widget.productId);
              if (context.mounted) context.pop();
            },
            child: Text('Remove', style: AppTypography.labelMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(shelfProvider); // rebuild on shelf changes (favourite, delete)
    final product = _product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Product', style: AppTypography.h4)),
        body: const Center(child: Text('Product not found')),
      );
    }
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(product: product, onBack: () => context.pop(), onDelete: _confirmDelete),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _enterAnim,
                  builder: (_, _) => Opacity(
                    opacity: _enterAnim.value.clamp(0.0, 1.0),
                    child: Column(
                      children: [
                        _ExpiryCard(product: product),
                        const SizedBox(height: 14),
                        _CompatibilityCard(product: product, progress: _enterAnim.value),
                        const SizedBox(height: 14),
                        if (product.benefits.isNotEmpty) _BenefitsCard(product: product),
                        if (product.benefits.isNotEmpty) const SizedBox(height: 14),
                        _IngredientsCard(product: product),
                        const SizedBox(height: 14),
                        if (product.howToUse.isNotEmpty) _HowToUseCard(product: product),
                        if (product.howToUse.isNotEmpty) const SizedBox(height: 14),
                        _ProductInfoCard(product: product),
                        const SizedBox(height: 20),
                        _ActionButtons(product: product),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero AppBar ───────────────────────────────────────────────────────────────

class _HeroAppBar extends StatelessWidget {
  final ShelfProduct product;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  const _HeroAppBar({required this.product, required this.onBack, required this.onDelete});

  Color get _scoreColor {
    if (product.score >= 85) return AppColors.success;
    if (product.score >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF1E1B4B),
      leading: _CircleBtn(icon: Icons.arrow_back_rounded, onTap: onBack),
      actions: [
        _CircleBtn(icon: Icons.edit_outlined, onTap: () {}),
        _CircleBtn(icon: Icons.delete_outline_rounded, onTap: onDelete),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative blobs
              Positioned(
                top: -30, right: -20,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: 10, left: -30,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: product.color.withValues(alpha: 0.14),
                  ),
                ),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Thumbnail + name row
                      Row(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: product.color.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                            ),
                            child: Icon(Icons.spa_rounded, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.name,
                                  style: AppTypography.h4.copyWith(color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  product.brand,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Score + favourite row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _scoreColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _scoreColor.withValues(alpha: 0.5), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_rounded, color: _scoreColor, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Safety ${product.score}',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: _scoreColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (product.isFavourite)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.favorite_rounded, color: Color(0xFFEC4899), size: 14),
                                  SizedBox(width: 5),
                                  Text(
                                    'Favourite',
                                    style: TextStyle(
                                      color: Color(0xFFEC4899),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _CircleBtn ────────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── _ExpiryCard ───────────────────────────────────────────────────────────────

class _ExpiryCard extends StatelessWidget {
  final ShelfProduct product;

  const _ExpiryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final status = product.expiryStatus;
    final daysLeft = product.daysLeft();
    final totalDays = product.expiryDate.difference(product.purchaseDate).inDays;
    final usedDays = DateTime.now().difference(product.purchaseDate).inDays.clamp(0, totalDays);
    final progress = totalDays > 0 ? (usedDays / totalDays).clamp(0.0, 1.0) : 1.0;

    final (statusLabel, statusColor, statusIcon) = switch (status) {
      ExpiryStatus.expired   => ('Expired', AppColors.error, Icons.warning_amber_rounded),
      ExpiryStatus.expiringSoon => ('Expiring Soon', AppColors.warning, Icons.timer_outlined),
      ExpiryStatus.good      => ('In Date', AppColors.success, Icons.check_circle_outline_rounded),
    };

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expiry Tracking', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      status == ExpiryStatus.expired
                        ? 'This product has expired'
                        : '$daysLeft days remaining',
                      style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: context.dColors.surfaceDim,
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withValues(alpha: 0.6), statusColor],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _DateLabel(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Purchased',
                  date: _fmtDate(product.purchaseDate),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _DateLabel(
                  icon: Icons.event_outlined,
                  label: 'Expires',
                  date: _fmtDate(product.expiryDate),
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _DateLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;
  final Color? color;

  const _DateLabel({required this.icon, required this.label, required this.date, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.dColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.caption.copyWith(color: context.dColors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(date,
                  style: AppTypography.labelMedium.copyWith(color: c, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

// ── _CompatibilityCard ────────────────────────────────────────────────────────

class _CompatibilityCard extends StatelessWidget {
  final ShelfProduct product;
  final double progress;

  const _CompatibilityCard({required this.product, required this.progress});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text('Compatibility', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          _CompatBar(label: 'Skin Match', score: product.skinMatch, progress: progress, color: AppColors.primary),
          const SizedBox(height: 12),
          _CompatBar(label: 'Hair Match', score: product.hairMatch, progress: progress, color: const Color(0xFF06B6D4)),
          const SizedBox(height: 12),
          _CompatBar(label: 'Safety Score', score: product.score, progress: progress,
            color: product.score >= 85 ? AppColors.success : product.score >= 70 ? AppColors.warning : AppColors.error),
        ],
      ),
    );
  }
}

class _CompatBar extends StatelessWidget {
  final String label;
  final int score;
  final double progress;
  final Color color;

  const _CompatBar({required this.label, required this.score, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary)),
            Text(
              '$score%',
              style: AppTypography.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 7,
          decoration: BoxDecoration(
            color: context.dColors.surfaceDim,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: (score / 100) * progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── _BenefitsCard ─────────────────────────────────────────────────────────────

class _BenefitsCard extends StatelessWidget {
  final ShelfProduct product;

  const _BenefitsCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Text('Key Benefits', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...product.benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6, height: 6,
                  margin: const EdgeInsets.only(top: 5, right: 10),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                Expanded(
                  child: Text(b, style: AppTypography.bodyMedium.copyWith(color: context.dColors.textSecondary)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── _IngredientsCard ──────────────────────────────────────────────────────────

class _IngredientsCard extends StatelessWidget {
  final ShelfProduct product;

  const _IngredientsCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text('Ingredients', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          if (product.safeIngredients.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'Safe (${product.safeIngredients.length})',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: product.safeIngredients.map((ing) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    ing,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
          if (product.cautionIngredients.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'Use With Caution (${product.cautionIngredients.length})',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: product.cautionIngredients.map((ing) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    ing,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── _HowToUseCard ─────────────────────────────────────────────────────────────

class _HowToUseCard extends StatelessWidget {
  final ShelfProduct product;

  const _HowToUseCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text('How To Use', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.howToUse,
            style: AppTypography.bodyMedium.copyWith(color: context.dColors.textSecondary, height: 1.55),
          ),
        ],
      ),
    );
  }
}

// ── _ProductInfoCard ──────────────────────────────────────────────────────────

class _ProductInfoCard extends StatelessWidget {
  final ShelfProduct product;

  const _ProductInfoCard({required this.product});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    String fmtDate(DateTime d) => '${months[d.month - 1]} ${d.year}';

    final rows = [
      ('Brand', product.brand, Icons.business_outlined),
      ('Category', product.category, Icons.category_outlined),
      ('Purchased', fmtDate(product.purchaseDate), Icons.shopping_bag_outlined),
      ('Expires', fmtDate(product.expiryDate), Icons.event_outlined),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text('Product Details', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(rows.length, (i) {
            final (label, value, icon) = rows[i];
            return Column(
              children: [
                if (i > 0) Divider(height: 1, color: context.dColors.divider),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: context.dColors.textTertiary),
                      const SizedBox(width: 8),
                      Text(label, style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          value,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium.copyWith(
                            color: context.dColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          if (product.notes.isNotEmpty) ...[
            Divider(height: 1, color: context.dColors.divider),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, size: 16, color: context.dColors.textTertiary),
                  const SizedBox(width: 8),
                  Text('Notes', style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary)),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      product.notes,
                      style: AppTypography.labelMedium.copyWith(color: context.dColors.textPrimary),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── _ActionButtons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final ShelfProduct product;

  const _ActionButtons({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppColors.elevatedShadow,
            ),
            child: TextButton.icon(
              onPressed: () => context.push('/routine'),
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
              label: Text('Add to Routine', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(28),
            ),
            child: TextButton.icon(
              onPressed: () => context.go('/scan/analysis/${product.id}'),
              icon: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
              label: Text(
                'Full Analysis',
                style: AppTypography.button.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 300.ms).slideY(begin: 0.06, duration: 350.ms);
  }
}

// ── _Card ─────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(color: context.dColors.borderLight, width: 0.8),
      ),
      child: child,
    );
  }
}

