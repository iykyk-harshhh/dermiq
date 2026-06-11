import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:dermiq/features/catalog/domain/product.dart';

Product _make({
  DateTime? expiry,
  bool fav = false,
  List<String> safe = const ['Glycerin'],
  List<String> caution = const [],
}) {
  return Product(
    id: 'x', name: 'Test', brand: 'Acme', category: 'Serum',
    score: 80, color: const Color(0xFF7C5CFF),
    expiryDate: expiry ?? DateTime.now().add(const Duration(days: 200)),
    purchaseDate: DateTime(2025, 1, 1),
    isFavourite: fav, safeIngredients: safe, cautionIngredients: caution,
  );
}

void main() {
  group('Product expiry', () {
    test('good when far in the future', () {
      final p = _make(expiry: DateTime.now().add(const Duration(days: 200)));
      expect(p.expiryStatus, ExpiryStatus.good);
      expect(p.daysLeft(), greaterThan(30));
    });

    test('expiringSoon within 30 days', () {
      final p = _make(expiry: DateTime.now().add(const Duration(days: 10)));
      expect(p.expiryStatus, ExpiryStatus.expiringSoon);
    });

    test('expired in the past', () {
      final p = _make(expiry: DateTime.now().subtract(const Duration(days: 5)));
      expect(p.expiryStatus, ExpiryStatus.expired);
      expect(p.daysLeft(), lessThanOrEqualTo(0));
    });
  });

  test('allIngredients merges safe + caution', () {
    final p = _make(safe: ['A', 'B'], caution: ['C']);
    expect(p.allIngredients, ['A', 'B', 'C']);
  });

  test('addedAt defaults to purchaseDate', () {
    final p = _make();
    expect(p.addedAt, p.purchaseDate);
  });

  test('copyWith changes only the requested field', () {
    final p = _make(fav: false);
    final c = p.copyWith(isFavourite: true);
    expect(c.isFavourite, true);
    expect(c.name, p.name);
    expect(c.id, p.id);
  });

  test('Firestore roundtrip preserves fields', () {
    final p = _make(fav: true, safe: ['Glycerin'], caution: ['Fragrance']);
    final restored = Product.fromFirestore(p.toFirestore(), p.id);
    expect(restored.id, p.id);
    expect(restored.name, p.name);
    expect(restored.brand, p.brand);
    expect(restored.score, p.score);
    expect(restored.isFavourite, true);
    expect(restored.color.toARGB32(), p.color.toARGB32());
    expect(restored.safeIngredients, p.safeIngredients);
    expect(restored.cautionIngredients, p.cautionIngredients);
    // DateTimes survive (to second precision via Timestamp).
    expect(restored.expiryDate.day, p.expiryDate.day);
  });

  test('fromFirestore tolerates missing fields', () {
    final p = Product.fromFirestore(<String, dynamic>{}, 'id1');
    expect(p.id, 'id1');
    expect(p.category, 'Other');
    expect(p.score, 80);
  });
}
