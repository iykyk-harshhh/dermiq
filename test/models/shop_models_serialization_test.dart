import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dermiq/features/shop/data/shop_models.dart';

const _product = ShopProduct(
  id: 'p1',
  name: 'Gentle Cleanser',
  brand: 'DermIQ',
  category: 'Skincare',
  subCategory: 'Cleanser',
  description: 'A gentle daily cleanser.',
  howToUse: 'Use twice daily.',
  price: 499,
  originalPrice: 699,
  rating: 4.5,
  reviewCount: 128,
  dermiqMatchScore: 88,
  accentColor: Color(0xFF6C4BFF),
  benefits: ['Hydrating', 'Soothing'],
  ingredients: ['Glycerin', 'Niacinamide'],
  skinTypes: ['Dry', 'Sensitive'],
  hairTypes: [],
  concerns: ['Dryness'],
  isFeatured: true,
);

const _address = Address(
  id: 'a1',
  fullName: 'Test User',
  phone: '9999999999',
  email: 'test@example.com',
  addressLine: '12 Main St',
  city: 'Bengaluru',
  state: 'KA',
  pincode: '560001',
  country: 'India',
);

void main() {
  test('ShopProduct round-trips through toMap/fromMap', () {
    final back = ShopProduct.fromMap(_product.toMap());
    expect(back.id, _product.id);
    expect(back.name, _product.name);
    expect(back.price, _product.price);
    expect(back.accentColor.toARGB32(), _product.accentColor.toARGB32());
    expect(back.benefits, _product.benefits);
    expect(back.isFeatured, isTrue);
  });

  test('CartItem round-trips and preserves quantity', () {
    const item = CartItem(product: _product, quantity: 3);
    final back = CartItem.fromMap(item.toMap());
    expect(back.quantity, 3);
    expect(back.product.id, 'p1');
    expect(back.lineTotal, _product.price * 3);
  });

  test('Order round-trips with items, address, enums and dates', () {
    final placed = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    final eta = placed.add(const Duration(days: 5));
    final order = Order(
      id: 'o123456789',
      items: const [CartItem(product: _product, quantity: 2)],
      subtotal: 998,
      deliveryCharge: 0,
      discountAmount: 100,
      total: 898,
      address: _address,
      paymentMethod: PaymentMethod.upi,
      placedAt: placed,
      estimatedDelivery: eta,
      status: OrderStatus.shipped,
    );
    final back = Order.fromMap(order.toMap());
    expect(back.id, order.id);
    expect(back.items.single.quantity, 2);
    expect(back.items.single.product.name, 'Gentle Cleanser');
    expect(back.address.city, 'Bengaluru');
    expect(back.paymentMethod, PaymentMethod.upi);
    expect(back.status, OrderStatus.shipped);
    expect(back.placedAt, placed);
    expect(back.estimatedDelivery, eta);
    expect(back.total, 898);
  });
}
