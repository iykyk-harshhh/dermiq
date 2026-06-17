import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';

enum OrderStatus { placed, confirmed, packed, shipped, outForDelivery, delivered, cancelled }

enum PaymentMethod { cod, upi, creditCard, debitCard, netBanking, wallet }

class ShopProduct {
  final String id;
  final String name;
  final String brand;
  final String category;       // 'Skincare' or 'Haircare'
  final String subCategory;    // 'Cleanser', 'Serum', etc.
  final String description;
  final String howToUse;
  final double price;          // INR
  final double originalPrice;  // before discount
  final double rating;         // 1.0–5.0
  final int reviewCount;
  final int dermiqMatchScore;  // 0–100
  final Color accentColor;
  final List<String> benefits;
  final List<String> ingredients;
  final List<String> skinTypes;
  final List<String> hairTypes;
  final List<String> concerns;
  final bool isFeatured;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.howToUse,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.dermiqMatchScore,
    required this.accentColor,
    this.benefits = const [],
    this.ingredients = const [],
    this.skinTypes = const [],
    this.hairTypes = const [],
    this.concerns = const [],
    this.isFeatured = false,
  });

  double get discountPct => originalPrice > price
      ? ((originalPrice - price) / originalPrice * 100)
      : 0;
  bool get hasDiscount => originalPrice > price;

  // Formatted price strings
  String get priceStr => Fmt.inr(price);
  String get originalPriceStr => Fmt.inr(originalPrice);
  String get discountStr => '${discountPct.toStringAsFixed(0)}% OFF';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'category': category,
        'subCategory': subCategory,
        'description': description,
        'howToUse': howToUse,
        'price': price,
        'originalPrice': originalPrice,
        'rating': rating,
        'reviewCount': reviewCount,
        'dermiqMatchScore': dermiqMatchScore,
        'accentColor': accentColor.toARGB32(),
        'benefits': benefits,
        'ingredients': ingredients,
        'skinTypes': skinTypes,
        'hairTypes': hairTypes,
        'concerns': concerns,
        'isFeatured': isFeatured,
      };

  factory ShopProduct.fromMap(Map<String, dynamic> m) => ShopProduct(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        brand: m['brand'] as String? ?? '',
        category: m['category'] as String? ?? '',
        subCategory: m['subCategory'] as String? ?? '',
        description: m['description'] as String? ?? '',
        howToUse: m['howToUse'] as String? ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0,
        originalPrice: (m['originalPrice'] as num?)?.toDouble() ?? 0,
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
        dermiqMatchScore: (m['dermiqMatchScore'] as num?)?.toInt() ?? 0,
        accentColor: Color((m['accentColor'] as num?)?.toInt() ?? 0xFF000000),
        benefits: (m['benefits'] as List?)?.cast<String>() ?? const [],
        ingredients: (m['ingredients'] as List?)?.cast<String>() ?? const [],
        skinTypes: (m['skinTypes'] as List?)?.cast<String>() ?? const [],
        hairTypes: (m['hairTypes'] as List?)?.cast<String>() ?? const [],
        concerns: (m['concerns'] as List?)?.cast<String>() ?? const [],
        isFeatured: m['isFeatured'] as bool? ?? false,
      );
}

class CartItem {
  final ShopProduct product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  double get lineTotal => product.price * quantity;

  Map<String, dynamic> toMap() => {
        'product': product.toMap(),
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        product: ShopProduct.fromMap(
            (m['product'] as Map).cast<String, dynamic>()),
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      );
}

class Address {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final String country;

  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  String get displayLine1 => fullName;
  String get displayLine2 => '$addressLine, $city, $state – $pincode';
  String get displayLine3 => country;

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'addressLine': addressLine,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
      };

  factory Address.fromMap(Map<String, dynamic> m) => Address(
        id: m['id'] as String? ?? '',
        fullName: m['fullName'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        email: m['email'] as String? ?? '',
        addressLine: m['addressLine'] as String? ?? '',
        city: m['city'] as String? ?? '',
        state: m['state'] as String? ?? '',
        pincode: m['pincode'] as String? ?? '',
        country: m['country'] as String? ?? '',
      );
}

class Coupon {
  final String code;
  final double discountPct; // e.g. 10 = 10%

  const Coupon({required this.code, required this.discountPct});
}

const availableCoupons = [
  Coupon(code: 'DERM10', discountPct: 10),
  Coupon(code: 'GLOW20', discountPct: 20),
  Coupon(code: 'FIRST15', discountPct: 15),
];

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double discountAmount;
  final double total;
  final Address address;
  final PaymentMethod paymentMethod;
  final DateTime placedAt;
  final DateTime estimatedDelivery;
  OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discountAmount,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.placedAt,
    required this.estimatedDelivery,
    this.status = OrderStatus.placed,
  });

  String get orderIdDisplay => '#DQ${id.substring(0, 6).toUpperCase()}';

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case PaymentMethod.cod:        return 'Cash on Delivery';
      case PaymentMethod.upi:        return 'UPI';
      case PaymentMethod.creditCard: return 'Credit Card';
      case PaymentMethod.debitCard:  return 'Debit Card';
      case PaymentMethod.netBanking: return 'Net Banking';
      case PaymentMethod.wallet:     return 'Wallet';
    }
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.placed:         return 'Order Placed';
      case OrderStatus.confirmed:      return 'Confirmed';
      case OrderStatus.packed:         return 'Packed';
      case OrderStatus.shipped:        return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered:      return 'Delivered';
      case OrderStatus.cancelled:      return 'Cancelled';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryCharge': deliveryCharge,
        'discountAmount': discountAmount,
        'total': total,
        'address': address.toMap(),
        'paymentMethod': paymentMethod.name,
        'placedAt': placedAt.millisecondsSinceEpoch,
        'estimatedDelivery': estimatedDelivery.millisecondsSinceEpoch,
        'status': status.name,
      };

  factory Order.fromMap(Map<String, dynamic> m) => Order(
        id: m['id'] as String,
        items: (m['items'] as List? ?? [])
            .map((e) => CartItem.fromMap((e as Map).cast<String, dynamic>()))
            .toList(),
        subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0,
        deliveryCharge: (m['deliveryCharge'] as num?)?.toDouble() ?? 0,
        discountAmount: (m['discountAmount'] as num?)?.toDouble() ?? 0,
        total: (m['total'] as num?)?.toDouble() ?? 0,
        address: Address.fromMap((m['address'] as Map).cast<String, dynamic>()),
        paymentMethod: PaymentMethod.values
            .byName(m['paymentMethod'] as String? ?? 'cod'),
        placedAt:
            DateTime.fromMillisecondsSinceEpoch((m['placedAt'] as num).toInt()),
        estimatedDelivery: DateTime.fromMillisecondsSinceEpoch(
            (m['estimatedDelivery'] as num).toInt()),
        status: OrderStatus.values.byName(m['status'] as String? ?? 'placed'),
      );
}

String paymentMethodLabel(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.cod:        return 'Cash on Delivery';
    case PaymentMethod.upi:        return 'UPI';
    case PaymentMethod.creditCard: return 'Credit Card';
    case PaymentMethod.debitCard:  return 'Debit Card';
    case PaymentMethod.netBanking: return 'Net Banking';
    case PaymentMethod.wallet:     return 'Wallets';
  }
}
