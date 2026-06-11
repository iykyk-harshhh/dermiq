import 'package:flutter_test/flutter_test.dart';
import 'package:dermiq/features/catalog/data/catalog_seed.dart';
import 'package:dermiq/features/catalog/data/ingredient_repository.dart';
import 'package:dermiq/features/catalog/data/product_repository.dart';
import 'package:dermiq/features/catalog/data/analysis_service.dart';

void main() {
  // Passing a null Firestore exercises the offline seed path.
  final products = ProductRepository(null);
  final ingredients = IngredientRepository(null);

  group('ProductRepository (seed)', () {
    test('search by name is case-insensitive', () async {
      final r = await products.search('retinol');
      expect(r, isNotEmpty);
      expect(r.every((p) => p.name.toLowerCase().contains('retinol')), isTrue);
    });

    test('search by brand', () async {
      final r = await products.search('cerave');
      expect(r.map((p) => p.brand), contains('CeraVe'));
    });

    test('empty query returns the whole catalog', () async {
      final r = await products.search('');
      expect(r.length, catalogProducts.length);
    });

    test('category filter narrows results', () async {
      final r = await products.search('', category: 'Sunscreen');
      expect(r, isNotEmpty);
      expect(r.every((p) => p.category == 'Sunscreen'), isTrue);
    });

    test('byId returns the matching product', () async {
      final p = await products.byId('1');
      expect(p, isNotNull);
      expect(p!.id, '1');
    });

    test('byId returns null for unknown id', () async {
      expect(await products.byId('does-not-exist'), isNull);
    });

    test('byBarcode resolves a seeded code', () async {
      final p = await products.byBarcode('8901030865278');
      expect(p, isNotNull);
      expect(p!.brand, 'CeraVe');
    });

    test('watchShelf offline emits the seed', () async {
      final list = await products.watchShelf('uid').first;
      expect(list.length, catalogProducts.length);
    });
  });

  group('IngredientRepository (seed)', () {
    test('search finds by function', () async {
      final r = await ingredients.search('hydration');
      expect(r, isNotEmpty);
    });

    test('byName fuzzy-matches', () async {
      final i = await ingredients.byName('Niacinamide 10%');
      expect(i, isNotNull);
      expect(i!.name, 'Niacinamide');
    });

    test('getMany resolves a product ingredient list', () async {
      final r = await ingredients.getMany(['Ceramide NP', 'Glycerin', 'Unobtainium']);
      final names = r.map((i) => i.name).toSet();
      expect(names, containsAll(['Ceramide NP', 'Glycerin']));
      expect(names, isNot(contains('Unobtainium')));
    });
  });

  group('ProductAnalysisService', () {
    final service = ProductAnalysisService(ingredients);

    test('clean product scores high with no flags', () async {
      final clean = catalogProducts.firstWhere((p) => p.id == '8'); // Niacinamide 10%
      final a = await service.analyze(clean);
      expect(a.flagged, isEmpty);
      expect(a.overallScore, greaterThanOrEqualTo(85));
      expect(a.verdict, 'Excellent');
    });

    test('flagged ingredient lowers score and is reported', () async {
      final retinol = catalogProducts.firstWhere((p) => p.id == '3');
      final a = await service.analyze(retinol);
      expect(a.flagged.map((i) => i.name), contains('Retinol'));
      expect(a.isClean, isFalse);
    });

    test('unknown ingredients are surfaced', () async {
      final service2 = ProductAnalysisService(ingredients);
      final p = catalogProducts.first.copyWith(
        safeIngredients: ['Glycerin', 'MysteryComplexX'],
        cautionIngredients: const [],
      );
      final a = await service2.analyze(p);
      expect(a.unknown, contains('MysteryComplexX'));
    });
  });
}
