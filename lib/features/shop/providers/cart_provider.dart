import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class CartState {
  final List<CartItem> items;
  final Coupon? appliedCoupon;

  const CartState({this.items = const [], this.appliedCoupon});

  double get subtotal => items.fold(0.0, (s, i) => s + i.lineTotal);
  double get deliveryCharge => subtotal > 999 ? 0.0 : 99.0; // free above ₹999
  double get discountAmount =>
      appliedCoupon != null ? subtotal * appliedCoupon!.discountPct / 100 : 0.0;
  double get total => subtotal + deliveryCharge - discountAmount;
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
  @override
  CartState build() => const CartState();

  void addItem(ShopProduct product) {
    // if already in cart, increment quantity
    final existing =
        state.items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[existing] =
          updated[existing].copyWith(quantity: updated[existing].quantity + 1);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
          items: [...state.items, CartItem(product: product)]);
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final updated = state.items
        .map((i) =>
            i.product.id == productId ? i.copyWith(quantity: qty) : i)
        .toList();
    state = state.copyWith(items: updated);
  }

  bool applyCoupon(String code) {
    final up = code.toUpperCase();
    var coupon =
        availableCoupons.where((c) => c.code.toUpperCase() == up).firstOrNull;
    // Also accept reward coupons earned via streak milestones.
    coupon ??= activeRewardCoupons(ref.read(streakProvider).valueOrNull)
        .where((c) => c.code.toUpperCase() == up)
        .firstOrNull;
    if (coupon == null) return false;
    state = state.copyWith(appliedCoupon: coupon);
    return true;
  }

  void removeCoupon() => state = state.copyWith(clearCoupon: true);

  void clear() => state = const CartState();
}

final cartProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
