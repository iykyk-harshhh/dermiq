import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/preferences_service.dart';
import '../../streak/data/streak_models.dart';
import '../../streak/providers/streak_provider.dart';
import '../data/shop_models.dart';

/// Coupons derived from the user's active reward gifts (a discount % parsed from
/// the reward name, e.g. "10% Off Skincare Products"). These are redeemable at
/// checkout alongside the standard [availableCoupons].
List<Coupon> activeRewardCoupons(StreakState? streak) {
  if (streak == null) return const [];
  final out = <Coupon>[];
  for (final r in streak.rewards) {
    if (r.status != RewardStatus.active) continue;
    final m = RegExp(r'(\d+)\s*%').firstMatch(r.name);
    if (m == null) continue;
    final pct = double.tryParse(m.group(1)!) ?? 0;
    if (pct <= 0) continue;
    out.add(Coupon(code: 'REWARD${pct.toInt()}', discountPct: pct));
  }
  return out;
}

/// Outcome of [CartNotifier.applyCoupon]: [ok] plus an [error] reason when
/// the coupon was rejected (null on success).
class CouponResult {
  final bool ok;
  final String? error;
  const CouponResult(this.ok, this.error);
}

class CartState {
  final List<CartItem> items;
  final Coupon? appliedCoupon;

  const CartState({this.items = const [], this.appliedCoupon});

  double get subtotal => items.fold(0.0, (s, i) => s + i.lineTotal);
  double get deliveryCharge => subtotal > 999 ? 0.0 : 99.0; // free above ₹999
  double get discountAmount =>
      appliedCoupon != null ? subtotal * appliedCoupon!.discountPct / 100 : 0.0;

  /// Order total after discount. Clamped to `>= 0` so a large discount (e.g. a
  /// reward coupon) can never produce a negative payable amount.
  double get total {
    final t = subtotal + deliveryCharge - discountAmount;
    return t < 0 ? 0.0 : t;
  }
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    Coupon? appliedCoupon,
    bool clearCoupon = false,
  }) =>
      CartState(
        items: items ?? this.items,
        appliedCoupon:
            clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      );
}

class CartNotifier extends Notifier<CartState> {
  /// Per-item quantity cap. A single line item can never exceed this many units.
  static const int maxQtyPerItem = 10;

  @override
  CartState build() => CartState(items: _loadItems());

  /// Reads the persisted cart (synchronous — `PreferencesService` is loaded at
  /// startup). The applied coupon is intentionally transient.
  static List<CartItem> _loadItems() {
    final raw = PreferencesService.cartJson;
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => CartItem.fromMap((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void _persist() {
    PreferencesService.setCartJson(
        jsonEncode(state.items.map((i) => i.toMap()).toList()));
  }

  void addItem(ShopProduct product) {
    // if already in cart, increment quantity
    final existing =
        state.items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      final current = state.items[existing].quantity;
      if (current >= maxQtyPerItem) return; // already at the cap — no-op
      final updated = List<CartItem>.from(state.items);
      updated[existing] = updated[existing].copyWith(quantity: current + 1);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
          items: [...state.items, CartItem(product: product)]);
    }
    _persist();
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
    _persist();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final capped = qty > maxQtyPerItem ? maxQtyPerItem : qty;
    final updated = state.items
        .map((i) =>
            i.product.id == productId ? i.copyWith(quantity: capped) : i)
        .toList();
    state = state.copyWith(items: updated);
    _persist();
  }

  /// Applies a coupon code to the cart.
  ///
  /// Returns a result carrying success plus a human-readable reason on failure:
  /// - empty cart → rejected
  /// - unknown code → rejected
  /// - expired coupon → rejected (and never applied)
  /// - subtotal below the coupon's minimum order → rejected
  CouponResult applyCoupon(String code) {
    if (state.isEmpty) {
      return const CouponResult(false, 'Add items to your cart first');
    }
    final up = code.toUpperCase();
    var coupon =
        availableCoupons.where((c) => c.code.toUpperCase() == up).firstOrNull;
    // Also accept reward coupons earned via streak milestones.
    coupon ??= activeRewardCoupons(ref.read(streakProvider).valueOrNull)
        .where((c) => c.code.toUpperCase() == up)
        .firstOrNull;
    if (coupon == null) {
      return const CouponResult(false, 'Invalid coupon code');
    }
    if (coupon.isExpired) {
      return const CouponResult(false, 'This coupon has expired');
    }
    if (!coupon.meetsMinOrder(state.subtotal)) {
      return CouponResult(false,
          'Minimum order of ₹${coupon.minOrder.toStringAsFixed(0)} required');
    }
    state = state.copyWith(appliedCoupon: coupon);
    return const CouponResult(true, null);
  }

  void removeCoupon() => state = state.copyWith(clearCoupon: true);

  void clear() {
    state = const CartState();
    _persist();
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
