import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateShort = DateFormat('dd MMM yyyy');

    // Determine the stage index (0-based) from order status
    final stageIndex = _statusToStage(order.status);

    const stages = [
      (label: 'Order Placed', icon: Icons.receipt_long_rounded),
      (label: 'Packed', icon: Icons.inventory_2_rounded),
      (label: 'Shipped', icon: Icons.local_shipping_rounded),
      (label: 'Out for Delivery', icon: Icons.delivery_dining_rounded),
      (label: 'Delivered', icon: Icons.check_circle_rounded),
    ];

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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Track Order', style: AppTypography.h4),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.sp16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AppConstants.sp4),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusButton),
              ),
              alignment: Alignment.center,
              child: Text(
                order.orderIdDisplay,
                style: AppTypography.labelSmall
                    .copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.dColors.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH,
            vertical: AppConstants.sp20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order ID + date header ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.sp16),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusCard),
                boxShadow: AppColors.heroShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textOnDarkSub)),
                        const SizedBox(height: 2),
                        Text(order.orderIdDisplay,
                            style: AppTypography.labelLarge
                                .copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Placed on',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textOnDarkSub)),
                      const SizedBox(height: 2),
                      Text(
                        dateShort.format(order.placedAt),
                        style: AppTypography.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.05, end: 0),

            const SizedBox(height: AppConstants.sp24),

            Text('Delivery Status', style: AppTypography.h4)
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: AppConstants.sp4),

            Text('Estimated: ${dateShort.format(order.estimatedDelivery)}',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.success))
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms),

            const SizedBox(height: AppConstants.sp24),

            // ── Vertical stage stepper ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.sp20),
              decoration: BoxDecoration(
                color: context.dColors.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusCard),
                boxShadow: context.dColors.cardShadow,
              ),
              child: Column(
                children: List.generate(stages.length, (i) {
                  final stage = stages[i];
                  final isCompleted = i < stageIndex;
                  final isCurrent = i == stageIndex;
                  final isLast = i == stages.length - 1;

                  return _TrackingStageRow(
                    label: stage.label,
                    icon: stage.icon,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLast: isLast,
                    index: i,
                  );
                }),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.08, end: 0),

            const SizedBox(height: AppConstants.sp24),

            // ── Delivery address card ────────────────────────────────────────
            Text('Delivery Address', style: AppTypography.h4)
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms),

            const SizedBox(height: AppConstants.sp12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.sp16),
              decoration: BoxDecoration(
                color: context.dColors.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: context.dColors.cardShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.location_on_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: AppConstants.sp12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.address.fullName,
                            style: AppTypography.labelMedium),
                        const SizedBox(height: 2),
                        Text(order.address.displayLine2,
                            style: AppTypography.bodySmall),
                        Text(order.address.displayLine3,
                            style: AppTypography.caption),
                        const SizedBox(height: AppConstants.sp4),
                        Text('Ph: ${order.address.phone}',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 450.ms, duration: 400.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppConstants.sp24),

            // ── Items summary ────────────────────────────────────────────────
            Text('Items in this order', style: AppTypography.h4)
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms),

            const SizedBox(height: AppConstants.sp12),

            ...order.items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.sp8),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.sp16,
                    vertical: AppConstants.sp12),
                decoration: BoxDecoration(
                  color: context.dColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                  boxShadow: context.dColors.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
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
                    const SizedBox(width: AppConstants.sp12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: AppTypography.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('Qty: ${item.quantity}',
                              style: AppTypography.caption),
                        ],
                      ),
                    ),
                    Text('₹${item.lineTotal.toStringAsFixed(0)}',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                      delay: Duration(milliseconds: 550 + i * 60),
                      duration: 350.ms)
                  .slideX(begin: 0.04, end: 0);
            }),

            const SizedBox(height: AppConstants.sp32),
          ],
        ),
      ),
    );
  }

  int _statusToStage(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.packed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
    }
  }
}

class _TrackingStageRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final int index;

  const _TrackingStageRow({
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color circleColor;
    Color circleBorder;
    Color iconColor;
    Color lineColor;

    if (isCompleted) {
      circleColor = AppColors.success;
      circleBorder = AppColors.success;
      iconColor = Colors.white;
      lineColor = AppColors.success;
    } else if (isCurrent) {
      circleColor = AppColors.primary.withValues(alpha: 0.1);
      circleBorder = AppColors.primary;
      iconColor = AppColors.primary;
      lineColor = context.dColors.borderLight;
    } else {
      circleColor = context.dColors.surfaceDim;
      circleBorder = context.dColors.borderMedium;
      iconColor = context.dColors.textTertiary;
      lineColor = context.dColors.borderLight;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: circle + connecting line
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: circleBorder, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : Icon(icon, color: iconColor, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.sp12),
          // Right: label + badge
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 6,
                  bottom: isLast ? 0 : AppConstants.sp20),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium.copyWith(
                        color: isCompleted || isCurrent
                            ? context.dColors.textPrimary
                            : context.dColors.textTertiary,
                      ),
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: AppConstants.sp8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.sp8,
                          vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusButton),
                      ),
                      child: Text(
                        'In Progress',
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 200 + index * 80),
            duration: 350.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

