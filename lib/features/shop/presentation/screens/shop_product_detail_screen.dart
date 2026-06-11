import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';
import '../../providers/cart_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopProductDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

class ShopProductDetailScreen extends ConsumerStatefulWidget {
  const ShopProductDetailScreen({super.key, required this.product});

  final ShopProduct product;

  @override
  ConsumerState<ShopProductDetailScreen> createState() =>
      _ShopProductDetailScreenState();
}

class _ShopProductDetailScreenState
    extends ConsumerState<ShopProductDetailScreen> {
  bool _wishlisted = false;

  ShopProduct get _p => widget.product;

  void _addToCart() {
    ref.read(cartProvider.notifier).addItem(_p);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_p.name} added to cart',
          style: AppTypography.labelMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _orderNow() {
    ref.read(cartProvider.notifier).addItem(_p);
    if (!mounted) return;
    context.push('/shop/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      bottomNavigationBar: _BottomBar(
        onAddToCart: _addToCart,
        onOrderNow: _orderNow,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _p.accentColor,
            surfaceTintColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(AppConstants.sp8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _wishlisted = !_wishlisted),
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.sp8),
                  padding: const EdgeInsets.all(AppConstants.sp8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _wishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.sp8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _p.accentColor,
                      _p.accentColor.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppConstants.sp32),

                      // Brand initial circle
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _p.brand[0].toUpperCase(),
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontSize: 44,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                            duration: 600.ms,
                          ),

                      const SizedBox(height: AppConstants.sp12),

                      // Brand chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.sp12,
                          vertical: AppConstants.sp4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                        child: Text(
                          _p.brand,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.sp8),

                      // Product name
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.sp24,
                        ),
                        child: Text(
                          _p.name,
                          style: AppTypography.h3.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.sp24),

                  // Price Row
                  _PriceRow(product: _p)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: AppConstants.sp12),

                  // Rating Row
                  _RatingRow(product: _p)
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: AppConstants.sp20),

                  // DermIQ Match Score
                  _MatchScoreCard(score: _p.dermiqMatchScore)
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.15),

                  const SizedBox(height: AppConstants.sp24),

                  // Description
                  _SectionHeader(title: 'About'),
                  const SizedBox(height: AppConstants.sp8),
                  Text(
                    _p.description,
                    style: AppTypography.bodyMedium,
                  ).animate(delay: 160.ms).fadeIn(duration: 300.ms),

                  if (_p.benefits.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.sp24),
                    _SectionHeader(title: 'Benefits'),
                    const SizedBox(height: AppConstants.sp8),
                    ..._p.benefits.map(
                      (b) => _BulletItem(text: b),
                    ),
                  ],

                  if (_p.ingredients.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.sp24),
                    _SectionHeader(title: 'Key Ingredients'),
                    const SizedBox(height: AppConstants.sp8),
                    Wrap(
                      spacing: AppConstants.sp8,
                      runSpacing: AppConstants.sp8,
                      children: _p.ingredients
                          .map((ing) => _IngredientChip(label: ing))
                          .toList(),
                    ),
                  ],

                  if (_p.howToUse.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.sp24),
                    _SectionHeader(title: 'How to Use'),
                    const SizedBox(height: AppConstants.sp8),
                    Text(
                      _p.howToUse,
                      style: AppTypography.bodyMedium,
                    ),
                  ],

                  if (_p.skinTypes.isNotEmpty || _p.hairTypes.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.sp24),
                    _SectionHeader(title: 'Suitable For'),
                    const SizedBox(height: AppConstants.sp8),
                    Wrap(
                      spacing: AppConstants.sp8,
                      runSpacing: AppConstants.sp8,
                      children: [
                        ..._p.skinTypes.map((s) => _TypeChip(label: s, icon: Icons.face_rounded)),
                        ..._p.hairTypes.map((h) => _TypeChip(label: h, icon: Icons.content_cut_rounded)),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppConstants.sp32),

                  // Reviews Section
                  _SectionHeader(title: 'Customer Reviews'),
                  const SizedBox(height: AppConstants.sp4),
                  Row(
                    children: [
                      Text(
                        _p.rating.toStringAsFixed(1),
                        style: AppTypography.metricSmall,
                      ),
                      const SizedBox(width: AppConstants.sp8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < _p.rating.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: AppColors.warning,
                                size: 16,
                              );
                            }),
                          ),
                          Text(
                            '${_p.reviewCount} reviews',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.sp16),

                  ..._mockReviews(_p).asMap().entries.map(
                        (e) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppConstants.sp12),
                          child: _MockReviewCard(review: e.value)
                              .animate(
                                  delay: Duration(milliseconds: 80 * e.key))
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.1),
                        ),
                      ),

                  // Bottom spacer for nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock review data
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewData {
  const _ReviewData({
    required this.name,
    required this.rating,
    required this.text,
    required this.date,
  });
  final String name;
  final double rating;
  final String text;
  final String date;
}

List<_ReviewData> _mockReviews(ShopProduct p) => [
      _ReviewData(
        name: 'Anika S.',
        rating: 5.0,
        text:
            'Absolutely love this product! It really works for my skin and I noticed a visible difference within 2 weeks of use.',
        date: '12 May 2025',
      ),
      _ReviewData(
        name: 'Rohan M.',
        rating: p.rating.clamp(3.5, 5.0),
        text:
            'Great product for the price. The formula is lightweight and absorbs quickly. Would definitely repurchase.',
        date: '3 Apr 2025',
      ),
      _ReviewData(
        name: 'Priya K.',
        rating: (p.rating - 0.3).clamp(3.0, 5.0),
        text:
            'Good product overall. Shipping was fast and packaging was intact. I\'ve been using it for a month now.',
        date: '18 Mar 2025',
      ),
    ];

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});
  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          product.priceStr,
          style: AppTypography.h2.copyWith(color: AppColors.primary),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: AppConstants.sp8),
          Text(
            product.originalPriceStr,
            style: AppTypography.bodyMedium.copyWith(
              decoration: TextDecoration.lineThrough,
              color: context.dColors.textTertiary,
            ),
          ),
          const SizedBox(width: AppConstants.sp8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.sp8,
              vertical: AppConstants.sp4,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusXS),
            ),
            child: Text(
              product.discountStr,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});
  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < product.rating.floor()
                ? Icons.star_rounded
                : (i < product.rating ? Icons.star_half_rounded : Icons.star_border_rounded),
            color: AppColors.warning,
            size: 18,
          );
        }),
        const SizedBox(width: AppConstants.sp8),
        Text(
          product.rating.toStringAsFixed(1),
          style: AppTypography.labelMedium.copyWith(
            color: context.dColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppConstants.sp4),
        Text(
          '(${product.reviewCount} reviews)',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _MatchScoreCard extends StatelessWidget {
  const _MatchScoreCard({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final pct = score / 100.0;
    return Container(
      padding: const EdgeInsets.all(AppConstants.sp16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.lavender.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.dColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.sp8),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppConstants.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DermIQ Match Score',
                      style: AppTypography.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Based on your skin & hair profile',
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.sp8),
              Text(
                '$score',
                style: AppTypography.metricSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                '/100',
                style: AppTypography.bodySmall
                    .copyWith(color: context.dColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.sp12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: context.dColors.borderLight,
                ),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: context.dColors.textPrimary,
        fontSize: 16,
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.sp8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: AppConstants.sp8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.sp12,
        vertical: AppConstants.sp4,
      ),
      decoration: BoxDecoration(
        color: context.dColors.surfaceDim,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.dColors.borderLight),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.sp12,
        vertical: AppConstants.sp8,
      ),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.dColors.borderMedium),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: AppConstants.sp4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: context.dColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockReviewCard extends StatelessWidget {
  const _MockReviewCard({required this.review});
  final _ReviewData review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.sp16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.name[0].toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name, style: AppTypography.labelMedium),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.warning,
                            size: 12,
                          );
                        }),
                        const SizedBox(width: AppConstants.sp4),
                        Text(
                          review.date,
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.sp8),
          Text(
            review.text,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomBar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onAddToCart, required this.onOrderNow});

  final VoidCallback onAddToCart;
  final VoidCallback onOrderNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.screenPaddingH,
        right: AppConstants.screenPaddingH,
        top: AppConstants.sp12,
        bottom: MediaQuery.of(context).padding.bottom + AppConstants.sp12,
      ),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        boxShadow: AppColors.bottomNavShadow,
      ),
      child: Row(
        children: [
          // Add to Cart — outlined
          Expanded(
            child: GestureDetector(
              onTap: onAddToCart,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppConstants.sp8),
                    Flexible(
                      child: Text(
                        'Add to Cart',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: AppConstants.sp12),

          // Order Now — filled gradient
          Expanded(
            child: GestureDetector(
              onTap: onOrderNow,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                  boxShadow: AppColors.elevatedShadow,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: AppConstants.sp8),
                    Flexible(
                      child: Text(
                        'Order Now',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }
}
