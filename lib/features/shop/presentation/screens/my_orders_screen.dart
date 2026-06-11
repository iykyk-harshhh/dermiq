import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';
import '../../providers/order_provider.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

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
        title: Text('My Orders', style: AppTypography.h4),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.dColors.borderLight),
        ),
      ),
      body: orders.isEmpty
          ? _buildEmptyState(context)
          : _buildOrderList(context, orders),
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
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.primary, size: 48),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: AppConstants.sp20),
          Text('No orders yet',
                  style: AppTypography.h4
                      .copyWith(color: context.dColors.textSecondary))
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppConstants.sp8),
          Text('Your past orders will appear here',
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
              child: Text('Start Shopping',
                  style: AppTypography.button
                      .copyWith(color: AppColors.textOnDark)),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppConstants.screenPaddingH,
          AppConstants.sp16,
          AppConstants.screenPaddingH,
          AppConstants.sp32),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        return _OrderCard(order: orders[i], index: i);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final int index;

  const _OrderCard({required this.order, required this.index});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return AppColors.primary;
      case OrderStatus.packed:
        return AppColors.warning;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.outForDelivery:
        return AppColors.warning;
      case OrderStatus.delivered:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusColor = _statusColor(order.status);
    final visibleItems =
        order.items.length > 2 ? order.items.sublist(0, 2) : order.items;
    final extraCount = order.items.length - visibleItems.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.sp12),
      padding: const EdgeInsets.all(AppConstants.sp16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: order ID + status badge ─────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AppConstants.sp4),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
                child: Text(order.orderIdDisplay,
                    style: AppTypography.labelSmall
                        .copyWith(color: Colors.white, fontSize: 11)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AppConstants.sp4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  order.statusLabel,
                  style: AppTypography.labelSmall
                      .copyWith(color: statusColor, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.sp12),
          Container(height: 1, color: context.dColors.borderLight),
          const SizedBox(height: AppConstants.sp12),

          // ── Product list ─────────────────────────────────────────────────
          ...visibleItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.sp8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.product.accentColor
                            .withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.product.brand.substring(0, 1),
                        style: AppTypography.labelSmall
                            .copyWith(color: item.product.accentColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: AppTypography.bodySmall
                            .copyWith(color: context.dColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('×${item.quantity}',
                        style: AppTypography.caption),
                  ],
                ),
              )),

          if (extraCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.sp8),
              child: Text(
                '+$extraCount more item${extraCount > 1 ? 's' : ''}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.primary),
              ),
            ),

          Container(height: 1, color: context.dColors.borderLight),
          const SizedBox(height: AppConstants.sp12),

          // ── Footer: total + date + track button ──────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total',
                      style: AppTypography.caption),
                  Text(
                    '₹${order.total.toStringAsFixed(0)}',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(width: AppConstants.sp16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Placed on',
                        style: AppTypography.caption),
                    Text(
                      dateFormat.format(order.placedAt),
                      style: AppTypography.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.sp8),
              GestureDetector(
                onTap: () => context.push(
                    '/order-tracking/${order.id}',
                    extra: order),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.sp12,
                      vertical: AppConstants.sp8),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusButton),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_shipping_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: AppConstants.sp4),
                      Text('Track',
                          style: AppTypography.buttonSmall
                              .copyWith(color: Colors.white)),
                    ],
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
            delay: Duration(milliseconds: index * 80),
            duration: 400.ms)
        .slideY(begin: 0.06, end: 0);
  }
}

