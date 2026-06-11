import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dermiq/features/catalog/domain/product.dart';
import 'package:dermiq/features/shelf/providers/shelf_provider.dart';

void main() {
  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('seeds the catalog and filters default to all', () {
    final c = makeContainer();
    final s = c.read(shelfProvider);
    expect(s.products.length, 8);
    expect(s.filtered.length, 8);
    expect(s.favouritesCount, 3);
  });

  test('favourites tab filters to favourites', () {
    final c = makeContainer();
    c.read(shelfProvider.notifier).setTab(ShelfTab.favourites);
    expect(c.read(shelfProvider).filtered.length, 3);
  });

  test('expiring tab is consistent with expiringCount', () {
    final c = makeContainer();
    c.read(shelfProvider.notifier).setTab(ShelfTab.expiring);
    final s = c.read(shelfProvider);
    expect(s.filtered.length, s.expiringCount);
  });

  test('category filter narrows to a category', () {
    final c = makeContainer();
    c.read(shelfProvider.notifier).setCategory(3); // Serum
    final list = c.read(shelfProvider).filtered;
    expect(list, isNotEmpty);
    expect(list.every((p) => p.category == 'Serum'), isTrue);
  });

  test('search by brand', () {
    final c = makeContainer();
    c.read(shelfProvider.notifier).setQuery('cerave');
    expect(c.read(shelfProvider).filtered.length, 1);
  });

  test('toggleFavourite flips a product', () {
    final c = makeContainer();
    final before = c.read(shelfProvider.notifier).byId('3')!.isFavourite;
    c.read(shelfProvider.notifier).toggleFavourite('3');
    expect(c.read(shelfProvider.notifier).byId('3')!.isFavourite, !before);
  });

  test('add then remove a product', () {
    final c = makeContainer();
    final n = c.read(shelfProvider.notifier);
    final product = Product(
      id: 'temp', name: 'New Serum', brand: 'Lab', category: 'Serum',
      score: 70, color: const Color(0xFF7C5CFF),
      expiryDate: DateTime.now().add(const Duration(days: 100)),
      purchaseDate: DateTime.now(),
    );
    n.addProduct(product);
    expect(c.read(shelfProvider).products.length, 9);
    expect(c.read(shelfProvider.notifier).byId('temp'), isNotNull);
    n.removeProduct('temp');
    expect(c.read(shelfProvider.notifier).byId('temp'), isNull);
    expect(c.read(shelfProvider).products.length, 8);
  });
}
