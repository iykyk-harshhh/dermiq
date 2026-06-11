import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/shop_models.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH,
              vertical: AppConstants.sp24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppConstants.sp32),

              // ── Success icon ────────────────────────────────────────────────
              _SuccessIcon()
                  .animate()
                  .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppConstants.sp24),

              // ── Heading ─────────────────────────────────────────────────────
              Text('Order Placed!', style: AppTypography.h2)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppConstants.sp8),

              Text(
                'Your order has been confirmed.\nWe\'ll notify you when it ships.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppConstants.sp32),

              // ── Order details card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.sp20),
                decoration: BoxDecoration(
                  color: context.dColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  boxShadow: context.dColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.sp12,
                              vertical: AppConstants.sp4),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusButton),
                          ),
                          child: Text(
                            order.orderIdDisplay,
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: AppConstants.sp4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusButton),
                          ),
                          child: Text(
                            order.statusLabel,
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.sp20),
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: dateFormat.format(order.placedAt),
                    ),
                    const SizedBox(height: AppConstants.sp12),
                    _DetailRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Amount',
                      value: '₹${order.total.toStringAsFixed(0)}',
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: AppConstants.sp12),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Deliver to',
                      value: order.address.displayLine2,
                    ),
                    const SizedBox(height: AppConstants.sp12),
                    _DetailRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Estimated Delivery',
                      value: dateFormat.format(order.estimatedDelivery),
                      valueColor: AppColors.success,
                    ),
                    const SizedBox(height: AppConstants.sp12),
                    _DetailRow(
                      icon: Icons.payment_rounded,
                      label: 'Payment',
                      value: order.paymentMethodDisplay,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .slideY(begin: 0.15, end: 0),

              const SizedBox(height: AppConstants.sp32),

              // ── CTA buttons ─────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go(
                    '/order-tracking/${order.id}',
                    extra: order),
                child: Container(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusButton),
                    boxShadow: context.dColors.cardShadow,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: AppConstants.sp8),
                      Text('Track Order',
                          style: AppTypography.button
                              .copyWith(color: AppColors.textOnDark)),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 650.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppConstants.sp12),

              GestureDetector(
                onTap: () => context.go('/shelf'),
                child: Container(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  decoration: BoxDecoration(
                    color: context.dColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusButton),
                    border: Border.all(color: context.dColors.borderMedium),
                  ),
                  alignment: Alignment.center,
                  child: Text('Continue Shopping',
                      style: AppTypography.button
                          .copyWith(color: AppColors.primary)),
                ),
              )
                  .animate()
                  .fadeIn(delay: 750.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppConstants.sp24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.08),
          ),
        ),
        // Inner ring
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.14),
          ),
        ),
        // Icon circle
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check_rounded,
              color: Colors.white, size: 36),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.dColors.surfaceDim,
            borderRadius: BorderRadius.circular(AppConstants.radiusXS),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: AppConstants.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.labelMedium.copyWith(
                    color: valueColor ?? context.dColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

