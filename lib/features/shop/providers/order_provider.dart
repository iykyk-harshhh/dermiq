import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/analytics_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shelf/data/shelf_models.dart';
import '../../shelf/providers/shelf_provider.dart';
import '../data/order_repository.dart';
import '../data/order_seed.dart';
import '../data/shop_models.dart';

class OrderNotifier extends Notifier<List<Order>> {
  OrderRepository get _repo => ref.read(orderRepositoryProvider);
  String? get _uid => ref.read(authStateProvider)?.id;

  @override
  List<Order> build() {
    // Stream order history from Firestore when signed in (survives restart);
    // otherwise fall back to an in-memory session list. Until the user has any
    // real orders, show realistic demo history so My Orders never looks empty.
    final uid = ref.watch(authStateProvider)?.id;
    if (uid != null && _repo.isOnline) {
      final sub = _repo.watch(uid).listen(
        (orders) => state = orders.isNotEmpty ? orders : seedDemoOrders(),
        onError: (Object e) => debugPrint('[Orders] watch error: $e'),
      );
      ref.onDispose(sub.cancel);
    }
    return seedDemoOrders();
  }

  /// Demo/seed orders live only in memory — never persisted to Firestore.
  bool _isDemo(String orderId) => orderId.startsWith('demo');

  /// Places a new order, prepends it to the list, and returns the placed [Order].
  Order placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double deliveryCharge,
    required double discountAmount,
    required double total,
    required Address address,
    required PaymentMethod paymentMethod,
  }) {
    final now = DateTime.now();
    final order = Order(
      id: now.millisecondsSinceEpoch.toString(),
      items: items,
      subtotal: subtotal,
      deliveryCharge: deliveryCharge,
      discountAmount: discountAmount,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      placedAt: now,
      estimatedDelivery: now.add(const Duration(days: 5)),
      status: OrderStatus.placed,
    );
    state = [order, ...state];
    // Persist to Firestore (no-op offline; the stream reconciles when online).
    final uid = _uid;
    if (uid != null) _repo.save(uid, order);
    // Analytics — Orders (no-op until Firebase is configured).
    ref.read(analyticsServiceProvider).logEvent('order_placed', {
      'total': total,
      'items': items.length,
    });
    return order;
  }

  /// Cancels an order (only while it hasn't been delivered).
  void cancelOrder(String orderId) {
    final idx = state.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    final s = state[idx].status;
    if (s == OrderStatus.delivered || s == OrderStatus.cancelled) return;
    state[idx].status = OrderStatus.cancelled;
    state = [...state];
    final uid = _uid;
    if (uid != null && !_isDemo(orderId)) {
      _repo.updateStatus(uid, orderId, OrderStatus.cancelled);
    }
  }

  /// Marks an order delivered and **auto-adds its products to My Shelf**
  /// (Order Delivered → Auto Add Product To Shelf, per spec).
  void markDelivered(String orderId) {
    final idx = state.indexWhere((o) => o.id == orderId);
    if (idx < 0 ||
        state[idx].status == OrderStatus.delivered ||
        state[idx].status == OrderStatus.cancelled) {
      return;
    }

    state[idx].status = OrderStatus.delivered; // status is mutable
    state = [...state]; // new reference so watchers rebuild

    final uid = _uid;
    if (uid != null && !_isDemo(orderId)) {
      _repo.updateStatus(uid, orderId, OrderStatus.delivered);
    }

    final shelf = ref.read(shelfProvider.notifier);
    final now = DateTime.now();
    for (final item in state[idx].items) {
      shelf.addProduct(_shelfProductFromShop(item.product, now));
    }
  }

  ShelfProduct _shelfProductFromShop(ShopProduct p, DateTime purchasedAt) =>
      ShelfProduct(
        id: 'shop_${p.id}_${purchasedAt.millisecondsSinceEpoch}',
        name: p.name,
        brand: p.brand,
        category: p.subCategory,
        score: p.dermiqMatchScore,
        color: p.accentColor,
        purchaseDate: purchasedAt,
        expiryDate: purchasedAt.add(const Duration(days: 365)),
        notes: 'Delivered from DermIQ Shop',
        benefits: p.benefits,
        howToUse: p.howToUse,
      );
}

final orderProvider =
    NotifierProvider<OrderNotifier, List<Order>>(OrderNotifier.new);
