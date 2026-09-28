import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_top_bar.dart';
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
        leading: const AppBackButton(),
        title: Text('My Orders', style: AppTypography.h4),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.dColors.borderLight),
        ),
      ),
      body: _buildOrderList(context, orders),
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

class _OrderCard extends ConsumerWidget {
  final Order order;
  final int index;

  const _OrderCard({required this.order, required this.index});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return AppColors.primary;
      case OrderStatus.confirmed:
        return AppColors.primary;
      case OrderStatus.packed:
        return AppColors.warning;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.outForDelivery:
        return AppColors.warning;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Order?', style: AppTypography.h4),
        content: Text('Order ${order.orderIdDisplay} will be cancelled.',
            style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep',
                style: AppTypography.buttonSmall
                    .copyWith(color: context.dColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(orderProvider.notifier).cancelOrder(order.id);
            },
            child: Text('Cancel Order',
                style: AppTypography.buttonSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusColor = _statusColor(order.displayStatus);
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
                  order.displayStatusLabel,
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
                        item.product.brand.isNotEmpty ? item.product.brand[0] : '?',
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
                    Fmt.inr(order.total),
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
              if (order.status != OrderStatus.delivered &&
                  order.status != OrderStatus.cancelled) ...[
                GestureDetector(
                  onTap: () => _confirmCancel(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.sp12,
                        vertical: AppConstants.sp8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusButton),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text('Cancel',
                        style: AppTypography.buttonSmall
                            .copyWith(color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: AppConstants.sp8),
              ],
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

