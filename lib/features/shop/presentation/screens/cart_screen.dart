import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../streak/providers/streak_provider.dart';
import '../../data/shop_models.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCode(String code) {
    if (code.isEmpty) return;
    final success = ref.read(cartProvider.notifier).applyCoupon(code);
    setState(() {
      _couponError = success ? null : 'Invalid coupon code';
    });
    if (success) _couponController.clear();
  }

  void _applyCoupon() => _applyCode(_couponController.text.trim());

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.dColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('My Cart', style: AppTypography.h4),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.dColors.borderLight),
        ),
      ),
      body: cart.isEmpty
          ? _buildEmptyState(context)
          : _buildCartContent(context, cart),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            child: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.primary, size: 48),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: AppConstants.sp20),
          Text('Your cart is empty',
                  style: AppTypography.h4
                      .copyWith(color: context.dColors.textSecondary))
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppConstants.sp8),
          Text('Discover products made for your skin',
                  style: AppTypography.bodyMedium)
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
          const SizedBox(height: AppConstants.sp32),
          GestureDetector(
            onTap: () => context.go('/shelf'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.sp32,
                  vertical: AppConstants.sp16),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusButton),
                boxShadow: context.dColors.cardShadow,
              ),
              child: Text('Shop Now',
                  style: AppTypography.button
                      .copyWith(color: AppColors.textOnDark)),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartState cart) {
    final rewardCoupons =
        activeRewardCoupons(ref.watch(streakProvider).valueOrNull);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                AppConstants.sp16,
                AppConstants.screenPaddingH,
                AppConstants.sp8),
            children: [
              ...cart.items.asMap().entries.map((entry) {
                return _CartItemTile(
                  item: entry.value,
                  index: entry.key,
                );
              }),
              const SizedBox(height: AppConstants.sp16),
              _CouponSection(
                controller: _couponController,
                appliedCoupon: cart.appliedCoupon,
                errorText: _couponError,
                rewardCoupons: rewardCoupons,
                onApply: _applyCoupon,
                onApplyCode: _applyCode,
                onRemove: () {
                  ref.read(cartProvider.notifier).removeCoupon();
                  setState(() => _couponError = null);
                },
              ),
              const SizedBox(height: AppConstants.sp16),
              _OrderSummaryCard(cart: cart),
              const SizedBox(height: AppConstants.sp24),
            ],
          ),
        ),
        _buildCheckoutButton(context, cart),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartState cart) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppConstants.screenPaddingH,
          AppConstants.sp16,
          AppConstants.screenPaddingH,
          AppConstants.sp16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        boxShadow: AppColors.bottomNavShadow,
      ),
      child: GestureDetector(
        onTap: () => context.push('/checkout'),
        child: Container(
          width: double.infinity,
          height: AppConstants.buttonHeight,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            boxShadow: context.dColors.cardShadow,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text('Proceed to Checkout',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.button
                        .copyWith(color: AppColors.textOnDark)),
              ),
              const SizedBox(width: AppConstants.sp8),
              Text('• ₹${cart.total.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.button
                      .copyWith(color: AppColors.textOnDarkSub)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  final int index;

  const _CartItemTile({required this.item, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.sp12),
      padding: const EdgeInsets.all(AppConstants.sp12),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          // Accent color product box
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: product.accentColor.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusSmall),
            ),
            alignment: Alignment.center,
            child: Text(
              product.brand.substring(0, 1).toUpperCase(),
              style: AppTypography.h3.copyWith(color: product.accentColor),
            ),
          ),
          const SizedBox(width: AppConstants.sp12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: AppTypography.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.brand,
                    style: AppTypography.caption),
                const SizedBox(height: AppConstants.sp8),
                Row(
                  children: [
                    _QuantityControl(
                      quantity: item.quantity,
                      onDecrement: () =>
                          ref.read(cartProvider.notifier).updateQuantity(
                                product.id,
                                item.quantity - 1,
                              ),
                      onIncrement: () =>
                          ref.read(cartProvider.notifier).updateQuantity(
                                product.id,
                                item.quantity + 1,
                              ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${item.lineTotal.toStringAsFixed(0)}',
                      style: AppTypography.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.sp4),
          // Remove button
          GestureDetector(
            onTap: () => ref
                .read(cartProvider.notifier)
                .removeItem(product.id),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusXS),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 18),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 60), duration: 350.ms)
        .slideX(begin: 0.06, end: 0);
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.dColors.surfaceDim,
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(icon: Icons.remove_rounded, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.sp8),
            child: Text(
              '$quantity',
              style: AppTypography.labelMedium,
            ),
          ),
          _QtyButton(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  final TextEditingController controller;
  final Coupon? appliedCoupon;
  final String? errorText;
  final List<Coupon> rewardCoupons;
  final VoidCallback onApply;
  final ValueChanged<String> onApplyCode;
  final VoidCallback onRemove;

  const _CouponSection({
    required this.controller,
    required this.appliedCoupon,
    required this.errorText,
    required this.rewardCoupons,
    required this.onApply,
    required this.onApplyCode,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.sp16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: context.dColors.borderLight),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: AppConstants.sp8),
              Text('Apply Coupon', style: AppTypography.labelLarge),
            ],
          ),
          if (appliedCoupon != null) ...[
            const SizedBox(height: AppConstants.sp12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.sp12,
                  vertical: AppConstants.sp8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusXS),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: AppConstants.sp8),
                  Expanded(
                    child: Text(
                      '${appliedCoupon!.code} applied — ${appliedCoupon!.discountPct.toInt()}% off',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                  const SizedBox(width: AppConstants.sp8),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.success, size: 16),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppConstants.sp12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.dColors.surfaceDim,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXS),
                      border: errorText != null
                          ? Border.all(
                              color: AppColors.error.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: TextField(
                      controller: controller,
                      style: AppTypography.labelMedium,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: AppTypography.bodySmall,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.sp12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.sp8),
                GestureDetector(
                  onTap: onApply,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.sp16),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    alignment: Alignment.center,
                    child: Text('Apply',
                        style: AppTypography.buttonSmall
                            .copyWith(color: AppColors.textOnDark)),
                  ),
                ),
              ],
            ),
            if (errorText != null) ...[
              const SizedBox(height: AppConstants.sp4),
              Text(errorText!,
                  style:
                      AppTypography.caption.copyWith(color: AppColors.error)),
            ],
            if (rewardCoupons.isNotEmpty) ...[
              const SizedBox(height: AppConstants.sp12),
              Text('Your reward coupons',
                  style: AppTypography.caption
                      .copyWith(color: context.dColors.textSecondary)),
              const SizedBox(height: AppConstants.sp8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rewardCoupons
                    .map((c) => GestureDetector(
                          onTap: () => onApplyCode(c.code),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusXS),
                              border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.card_giftcard_rounded,
                                    size: 13, color: AppColors.primary),
                                const SizedBox(width: 5),
                                Text(
                                  '${c.code} · ${c.discountPct.toInt()}% off',
                                  style: AppTypography.labelSmall
                                      .copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CartState cart;

  const _OrderSummaryCard({required this.cart});

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
          Text('Order Summary', style: AppTypography.labelLarge),
          const SizedBox(height: AppConstants.sp16),
          _SummaryRow(
              label: 'Subtotal',
              value: '₹${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: AppConstants.sp8),
          _SummaryRow(
            label: 'Delivery',
            value: cart.deliveryCharge == 0
                ? 'FREE'
                : '₹${cart.deliveryCharge.toStringAsFixed(0)}',
            valueColor:
                cart.deliveryCharge == 0 ? AppColors.success : null,
          ),
          if (cart.appliedCoupon != null) ...[
            const SizedBox(height: AppConstants.sp8),
            _SummaryRow(
              label: 'Discount (${cart.appliedCoupon!.code})',
              value: '−₹${cart.discountAmount.toStringAsFixed(0)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: AppConstants.sp12),
          Container(height: 1, color: context.dColors.borderLight),
          const SizedBox(height: AppConstants.sp12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTypography.labelLarge
                      .copyWith(fontSize: 16)),
              Text(
                '₹${cart.total.toStringAsFixed(0)}',
                style: AppTypography.labelLarge.copyWith(
                    fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppConstants.sp8),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
              color: valueColor ?? context.dColors.textPrimary),
        ),
      ],
    );
  }
}
