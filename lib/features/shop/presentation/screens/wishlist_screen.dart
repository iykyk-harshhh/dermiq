import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';
import '../../providers/wishlist_provider.dart';
import '../widgets/product_image.dart';

/// Lists the products the user has saved to their wishlist. Tapping a row opens
/// the product detail; the heart removes it. Persists via [wishlistProvider]
/// (Firestore when signed in, in-memory otherwise).
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.dColors.textPrimary, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.shop),
        ),
        title: Text('Wishlist', style: AppTypography.h4),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.dColors.borderLight),
        ),
      ),
      body: items.isEmpty
          ? _buildEmpty(context)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH,
                  vertical: AppConstants.sp20),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppConstants.sp12),
              itemBuilder: (context, i) {
                final product = items[i];
                return _WishlistRow(
                  product: product,
                  onOpen: () => context.push(
                      AppRoutes.shopProductDetail(product.id),
                      extra: product),
                  onRemove: () {
                    HapticFeedback.selectionClick();
                    ref.read(wishlistProvider.notifier).remove(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} removed from wishlist',
                            style: AppTypography.labelMedium
                                .copyWith(color: Colors.white)),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusSmall)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(
                        delay: Duration(milliseconds: 40 * i), duration: 300.ms)
                    .slideY(begin: 0.08, end: 0);
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border_rounded,
                color: AppColors.primary, size: 48),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: AppConstants.sp20),
          Text('Your wishlist is empty', style: AppTypography.h3),
          const SizedBox(height: AppConstants.sp8),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.sp32),
            child: Text(
              'Tap the heart on any product to save it here for later.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppConstants.sp24),
          GestureDetector(
            onTap: () => context.go(AppRoutes.shop),
            child: Container(
              height: 52,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConstants.sp32),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
              alignment: Alignment.center,
              child: Text('Browse Shop',
                  style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistRow extends StatelessWidget {
  const _WishlistRow({
    required this.product,
    required this.onOpen,
    required this.onRemove,
  });

  final ShopProduct product;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.sp12),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Row(
          children: [
            // Thumbnail (real image, brand-initial fallback).
            SizedBox(
              width: 64,
              height: 64,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: ProductImage(
                  product: product,
                  fit: BoxFit.cover,
                  fallback: Container(
                    color: product.accentColor.withValues(alpha: 0.15),
                    alignment: Alignment.center,
                    child: Text(
                      product.brand.isNotEmpty
                          ? product.brand[0].toUpperCase()
                          : '?',
                      style: AppTypography.h4
                          .copyWith(color: product.accentColor),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand,
                      style: AppTypography.caption
                          .copyWith(color: context.dColors.textTertiary)),
                  const SizedBox(height: 2),
                  Text(product.name,
                      style: AppTypography.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppConstants.sp4),
                  Row(
                    children: [
                      Text(product.priceStr,
                          style: AppTypography.labelLarge
                              .copyWith(color: AppColors.primary)),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: AppConstants.sp8),
                        Text(
                          product.originalPriceStr,
                          style: AppTypography.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: context.dColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.sp8),
            // Remove (filled heart) action.
            Semantics(
              button: true,
              label: 'Remove from wishlist',
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.sp8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: AppColors.error, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
