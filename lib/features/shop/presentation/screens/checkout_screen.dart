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
import '../../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  PaymentMethod _selectedPayment = PaymentMethod.cod;
  bool _isPlacingOrder = false;

  final _formKey = GlobalKey<FormState>();

  // Address form controllers
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    final cart = ref.read(cartProvider);
    setState(() => _isPlacingOrder = true);

    final address = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      addressLine: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
    );

    final order = ref.read(orderProvider.notifier).placeOrder(
          items: cart.items,
          subtotal: cart.subtotal,
          deliveryCharge: cart.deliveryCharge,
          discountAmount: cart.discountAmount,
          total: cart.total,
          address: address,
          paymentMethod: _selectedPayment,
        );

    ref.read(cartProvider.notifier).clear();

    if (!mounted) return;
    context.go('/order-success', extra: order);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: context.dColors.background,
        appBar: AppBar(
          backgroundColor: context.dColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.dColors.textPrimary, size: 20),
            onPressed: _goBack,
          ),
          title: Text('Checkout', style: AppTypography.h4),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.dColors.borderLight),
          ),
        ),
        body: Column(
          children: [
            _StepIndicator(currentStep: _step),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenPaddingH,
                    vertical: AppConstants.sp16),
                child: AnimatedSwitcher(
                  duration: 280.ms,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0.04, 0), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _AddressStep(
          formKey: _formKey,
          fullName: _fullNameCtrl,
          phone: _phoneCtrl,
          email: _emailCtrl,
          address: _addressCtrl,
          city: _cityCtrl,
          state: _stateCtrl,
          pincode: _pincodeCtrl,
          country: _countryCtrl,
          onContinue: () {
            if (_formKey.currentState!.validate()) {
              setState(() => _step = 1);
            }
          },
        );
      case 1:
        return _SummaryStep(
          cart: ref.watch(cartProvider),
          onContinue: () => setState(() => _step = 2),
        );
      case 2:
        return _PaymentStep(
          selected: _selectedPayment,
          onSelect: (m) => setState(() => _selectedPayment = m),
          isLoading: _isPlacingOrder,
          onPlaceOrder: _placeOrder,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Address', 'Summary', 'Payment'];

    return Container(
      color: context.dColors.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: AppConstants.sp16),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final lineIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: lineIdx < currentStep
                      ? AppColors.primary
                      : context.dColors.borderLight,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isCompleted = stepIdx < currentStep;
          final isActive = stepIdx == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: 250.ms,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? AppColors.primary
                      : context.dColors.surfaceDim,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 3)
                      : null,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : Text(
                        '${stepIdx + 1}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isActive
                              ? Colors.white
                              : context.dColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 72),
                child: Text(
                  labels[stepIdx],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: isActive || isCompleted
                        ? AppColors.primary
                        : context.dColors.textTertiary,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Step 0: Address ──────────────────────────────────────────────────────────

class _AddressStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullName, phone, email, address, city, state,
      pincode, country;
  final VoidCallback onContinue;

  const _AddressStep({
    required this.formKey,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Address', style: AppTypography.h4),
          const SizedBox(height: AppConstants.sp4),
          Text('Where should we deliver your order?',
              style: AppTypography.bodyMedium),
          const SizedBox(height: AppConstants.sp24),
          _FormField(controller: fullName, label: 'Full Name', hint: 'e.g. Priya Sharma'),
          _FormField(
              controller: phone,
              label: 'Phone Number',
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone),
          _FormField(
              controller: email,
              label: 'Email Address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress),
          _FormField(
              controller: address,
              label: 'Address',
              hint: 'House no., Street, Locality',
              maxLines: 2),
          Row(
            children: [
              Expanded(
                  child: _FormField(controller: city, label: 'City', hint: 'Mumbai')),
              const SizedBox(width: AppConstants.sp12),
              Expanded(
                  child: _FormField(controller: state, label: 'State', hint: 'Maharashtra')),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: _FormField(
                      controller: pincode,
                      label: 'Pincode',
                      hint: '400001',
                      keyboardType: TextInputType.number)),
              const SizedBox(width: AppConstants.sp12),
              Expanded(
                  child: _FormField(controller: country, label: 'Country', hint: 'India')),
            ],
          ),
          const SizedBox(height: AppConstants.sp32),
          _PrimaryButton(label: 'Continue', onTap: onContinue),
          const SizedBox(height: AppConstants.sp24),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall),
          const SizedBox(height: AppConstants.sp4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTypography.bodyLarge.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodySmall,
              filled: true,
              fillColor: context.dColors.surfaceDim,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.sp16,
                  vertical: AppConstants.sp12),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusInput),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusInput),
                borderSide: BorderSide(color: context.dColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusInput),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusInput),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusInput),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5),
              ),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '$label is required' : null,
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Summary ──────────────────────────────────────────────────────────

class _SummaryStep extends StatelessWidget {
  final CartState cart;
  final VoidCallback onContinue;

  const _SummaryStep({required this.cart, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: AppTypography.h4),
        const SizedBox(height: AppConstants.sp4),
        Text('Review your items before payment',
            style: AppTypography.bodyMedium),
        const SizedBox(height: AppConstants.sp24),
        Container(
          decoration: BoxDecoration(
            color: context.dColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            boxShadow: context.dColors.cardShadow,
          ),
          child: Column(
            children: [
              ...cart.items.map((item) => _SummaryItemRow(item: item)),
              Container(height: 1, color: context.dColors.borderLight,
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.sp16)),
              Padding(
                padding: const EdgeInsets.all(AppConstants.sp16),
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal',
                        value: '₹${cart.subtotal.toStringAsFixed(0)}'),
                    const SizedBox(height: AppConstants.sp8),
                    _TotalRow(
                      label: 'Delivery',
                      value: cart.deliveryCharge == 0
                          ? 'FREE'
                          : '₹${cart.deliveryCharge.toStringAsFixed(0)}',
                      valueColor: cart.deliveryCharge == 0
                          ? AppColors.success
                          : null,
                    ),
                    if (cart.appliedCoupon != null) ...[
                      const SizedBox(height: AppConstants.sp8),
                      _TotalRow(
                        label: 'Discount',
                        value: '−₹${cart.discountAmount.toStringAsFixed(0)}',
                        valueColor: AppColors.success,
                      ),
                    ],
                    const SizedBox(height: AppConstants.sp12),
                    Container(height: 1, color: context.dColors.borderLight),
                    const SizedBox(height: AppConstants.sp12),
                    _TotalRow(
                      label: 'Total',
                      value: '₹${cart.total.toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (cart.appliedCoupon != null) ...[
          const SizedBox(height: AppConstants.sp12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.sp12,
                vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_rounded,
                    color: AppColors.success, size: 16),
                const SizedBox(width: AppConstants.sp8),
                Expanded(
                  child: Text(
                    '${cart.appliedCoupon!.code} — ${cart.appliedCoupon!.discountPct.toInt()}% discount applied',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppConstants.sp32),
        _PrimaryButton(label: 'Proceed to Payment', onTap: onContinue),
        const SizedBox(height: AppConstants.sp24),
      ],
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  final CartItem item;

  const _SummaryItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.sp16, vertical: AppConstants.sp12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.product.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusXS),
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
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isBold
                ? AppTypography.labelLarge
                : AppTypography.bodyMedium),
        Text(
          value,
          style: isBold
              ? AppTypography.labelLarge.copyWith(
                  color: valueColor ?? AppColors.primary, fontSize: 16)
              : AppTypography.labelMedium.copyWith(
                  color: valueColor ?? context.dColors.textPrimary),
        ),
      ],
    );
  }
}

// ─── Step 2: Payment ──────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;
  final bool isLoading;
  final VoidCallback onPlaceOrder;

  const _PaymentStep({
    required this.selected,
    required this.onSelect,
    required this.isLoading,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      (PaymentMethod.cod, Icons.money_rounded, 'Cash on Delivery'),
      (PaymentMethod.upi, Icons.qr_code_rounded, 'UPI'),
      (PaymentMethod.creditCard, Icons.credit_card_rounded, 'Credit Card'),
      (PaymentMethod.debitCard, Icons.credit_card_outlined, 'Debit Card'),
      (PaymentMethod.netBanking, Icons.account_balance_rounded, 'Net Banking'),
      (PaymentMethod.wallet, Icons.account_balance_wallet_rounded, 'Wallets'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTypography.h4),
        const SizedBox(height: AppConstants.sp4),
        Text('Choose how you\'d like to pay',
            style: AppTypography.bodyMedium),
        const SizedBox(height: AppConstants.sp24),
        Container(
          decoration: BoxDecoration(
            color: context.dColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            boxShadow: context.dColors.cardShadow,
          ),
          child: Column(
            children: methods.asMap().entries.map((entry) {
              final i = entry.key;
              final (method, icon, label) = entry.value;
              final isSelected = selected == method;
              final isLast = i == methods.length - 1;

              return GestureDetector(
                onTap: () => onSelect(method),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.sp16,
                      vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.vertical(
                      top: i == 0
                          ? const Radius.circular(AppConstants.radiusCard)
                          : Radius.zero,
                      bottom: isLast
                          ? const Radius.circular(AppConstants.radiusCard)
                          : Radius.zero,
                    ),
                    border: !isLast
                        ? Border(
                            bottom:
                                BorderSide(color: context.dColors.borderLight))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : context.dColors.surfaceDim,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusXS),
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon,
                            color: isSelected
                                ? AppColors.primary
                                : context.dColors.textSecondary,
                            size: 20),
                      ),
                      const SizedBox(width: AppConstants.sp12),
                      Expanded(
                        child: Text(label,
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : context.dColors.textPrimary,
                            )),
                      ),
                      AnimatedContainer(
                        duration: 200.ms,
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : context.dColors.borderMedium,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 12)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppConstants.sp32),
        isLoading
            ? Container(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              )
            : _PrimaryButton(label: 'Place Order', onTap: onPlaceOrder),
        const SizedBox(height: AppConstants.sp24),
      ],
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppConstants.buttonHeight,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          boxShadow: context.dColors.cardShadow,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style:
                AppTypography.button.copyWith(color: AppColors.textOnDark)),
      ),
    );
  }
}

