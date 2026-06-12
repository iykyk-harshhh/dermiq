import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show Color;

enum ExpiryStatus { good, expiringSoon, expired }

/// Canonical product model — the single source of truth that replaces the old
/// scattered mock types (`ShelfProduct`, scan `_P`, …). Serializes to/from
/// Firestore; constructed directly for the offline seed catalog.
class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final int score; // 0–100 safety score
  final Color color; // thumbnail accent
  final DateTime expiryDate;
  final DateTime purchaseDate;
  final bool isFavourite;
  final bool isEmpty; // user marked the product as used up
  final String notes;
  final List<String> benefits;
  final List<String> safeIngredients;
  final List<String> cautionIngredients;
  final String howToUse;
  final int skinMatch; // 0–100
  final int hairMatch; // 0–100
  final String? imageUrl;
  final String? barcode;
  final DateTime addedAt;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.score,
    required this.color,
    required this.expiryDate,
    required this.purchaseDate,
    this.isFavourite = false,
    this.isEmpty = false,
    this.notes = '',
    this.benefits = const [],
    this.safeIngredients = const [],
    this.cautionIngredients = const [],
    this.howToUse = '',
    this.skinMatch = 80,
    this.hairMatch = 70,
    this.imageUrl,
    this.barcode,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? purchaseDate;

  /// All ingredient names, safe + caution, used for analysis.
  List<String> get allIngredients => [...safeIngredients, ...cautionIngredients];

  int daysLeft() => expiryDate.difference(DateTime.now()).inDays;

  ExpiryStatus get expiryStatus {
    final d = daysLeft();
    if (d <= 0) return ExpiryStatus.expired;
    if (d <= 30) return ExpiryStatus.expiringSoon;
    return ExpiryStatus.good;
  }

  Product copyWith({
    String? name,
    String? brand,
    String? category,
    int? score,
    Color? color,
    DateTime? expiryDate,
    DateTime? purchaseDate,
    bool? isFavourite,
    bool? isEmpty,
    String? notes,
    List<String>? benefits,
    List<String>? safeIngredients,
    List<String>? cautionIngredients,
    String? howToUse,
    int? skinMatch,
    int? hairMatch,
    String? imageUrl,
    String? barcode,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      score: score ?? this.score,
      color: color ?? this.color,
      expiryDate: expiryDate ?? this.expiryDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isFavourite: isFavourite ?? this.isFavourite,
      isEmpty: isEmpty ?? this.isEmpty,
      notes: notes ?? this.notes,
      benefits: benefits ?? this.benefits,
      safeIngredients: safeIngredients ?? this.safeIngredients,
      cautionIngredients: cautionIngredients ?? this.cautionIngredients,
      howToUse: howToUse ?? this.howToUse,
      skinMatch: skinMatch ?? this.skinMatch,
      hairMatch: hairMatch ?? this.hairMatch,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      addedAt: addedAt,
    );
  }

  // ── Firestore serialization ────────────────────────────────────────────────

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'brand': brand,
        'category': category,
        'score': score,
        'color': color.toARGB32(),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'purchaseDate': Timestamp.fromDate(purchaseDate),
        'isFavourite': isFavourite,
        'isEmpty': isEmpty,
        'notes': notes,
        'benefits': benefits,
        'safeIngredients': safeIngredients,
        'cautionIngredients': cautionIngredients,
        'howToUse': howToUse,
        'skinMatch': skinMatch,
        'hairMatch': hairMatch,
        'imageUrl': imageUrl,
        'barcode': barcode,
        'addedAt': Timestamp.fromDate(addedAt),
      };

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime ts(dynamic v, [DateTime? fallback]) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return fallback ?? DateTime.now();
    }

    final purchase = ts(data['purchaseDate']);
    return Product(
      id: id,
      name: data['name'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      score: (data['score'] as num?)?.toInt() ?? 80,
      color: Color((data['color'] as num?)?.toInt() ?? 0xFF7C5CFF),
      expiryDate: ts(data['expiryDate'],
          purchase.add(const Duration(days: 365))),
      purchaseDate: purchase,
      isFavourite: data['isFavourite'] as bool? ?? false,
      isEmpty: data['isEmpty'] as bool? ?? false,
      notes: data['notes'] as String? ?? '',
      benefits: List<String>.from(data['benefits'] ?? const []),
      safeIngredients: List<String>.from(data['safeIngredients'] ?? const []),
      cautionIngredients:
          List<String>.from(data['cautionIngredients'] ?? const []),
      howToUse: data['howToUse'] as String? ?? '',
      skinMatch: (data['skinMatch'] as num?)?.toInt() ?? 80,
      hairMatch: (data['hairMatch'] as num?)?.toInt() ?? 70,
      imageUrl: data['imageUrl'] as String?,
      barcode: data['barcode'] as String?,
      addedAt: ts(data['addedAt'], purchase),
    );
  }
}
