import 'shop_models.dart';
import 'shop_seed.dart';

/// Realistic demo order history so a fresh account's **My Orders** screen looks
/// alive (and the order-tracking UI is demoable) instead of empty. Mirrors the
/// appointment-seed pattern: shown until the user places a real order or
/// Firestore streams their actual history.
///
/// A function (not a const) because the dates are relative to "now".
List<Order> seedDemoOrders() {
  final now = DateTime.now();

  ShopProduct byIndex(int i) => shopProducts[i % shopProducts.length];

  const address = Address(
    id: 'demo_addr',
    fullName: 'Aanya Sharma',
    phone: '+91 98765 43210',
    email: 'aanya@example.com',
    addressLine: '402, Lotus Residency, MG Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560001',
    country: 'India',
  );

  Order build({
    required String id,
    required List<CartItem> items,
    required DateTime placedAt,
    required DateTime estimatedDelivery,
    required PaymentMethod paymentMethod,
    required OrderStatus status,
  }) {
    final subtotal = items.fold<double>(0, (s, i) => s + i.lineTotal);
    final delivery = subtotal > 999 ? 0.0 : 99.0;
    return Order(
      id: id,
      items: items,
      subtotal: subtotal,
      deliveryCharge: delivery,
      discountAmount: 0,
      total: subtotal + delivery,
      address: address,
      paymentMethod: paymentMethod,
      placedAt: placedAt,
      estimatedDelivery: estimatedDelivery,
      status: status,
    );
  }

  return [
    // Most recent — in transit (great for demoing the tracking timeline).
    build(
      id: 'demo0002000000',
      items: [
        CartItem(product: byIndex(0)),
        CartItem(product: byIndex(7), quantity: 2),
      ],
      placedAt: now.subtract(const Duration(days: 2)),
      estimatedDelivery: now.add(const Duration(days: 1)),
      paymentMethod: PaymentMethod.upi,
      status: OrderStatus.outForDelivery,
    ),
    // Older — delivered.
    build(
      id: 'demo0001000000',
      items: [
        CartItem(product: byIndex(3)),
      ],
      placedAt: now.subtract(const Duration(days: 12)),
      estimatedDelivery: now.subtract(const Duration(days: 7)),
      paymentMethod: PaymentMethod.cod,
      status: OrderStatus.delivered,
    ),
  ];
}
