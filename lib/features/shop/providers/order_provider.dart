import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/shop_models.dart';

class OrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => [];

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
    return order;
  }
}

final orderProvider =
    NotifierProvider<OrderNotifier, List<Order>>(OrderNotifier.new);
