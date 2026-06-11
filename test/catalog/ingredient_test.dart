import 'package:flutter_test/flutter_test.dart';
import 'package:dermiq/features/catalog/domain/ingredient.dart';

void main() {
  const ing = Ingredient(
    id: 'niacinamide', name: 'Niacinamide', inciName: 'Niacinamide',
    category: 'Active', function: 'Brightening', description: 'Vitamin B3',
    safetyScore: 95, flagged: false,
    benefits: ['Evens tone'], concerns: [], suitableFor: ['Oily'],
  );

  test('key is normalised lower-case', () {
    expect(ing.key, 'niacinamide');
    const spaced = Ingredient(
      id: 'x', name: '  Hyaluronic Acid ', inciName: '', category: '',
      function: '', description: '', safetyScore: 90,
    );
    expect(spaced.key, 'hyaluronic acid');
  });

  test('Firestore roundtrip preserves fields', () {
    final restored = Ingredient.fromFirestore(ing.toFirestore(), ing.id);
    expect(restored.name, ing.name);
    expect(restored.safetyScore, 95);
    expect(restored.flagged, false);
    expect(restored.benefits, ['Evens tone']);
    expect(restored.suitableFor, ['Oily']);
  });

  test('toFirestore denormalises a searchKey', () {
    expect(ing.toFirestore()['searchKey'], 'niacinamide');
  });

  test('fromFirestore defaults missing fields', () {
    final i = Ingredient.fromFirestore(<String, dynamic>{}, 'id1');
    expect(i.id, 'id1');
    expect(i.safetyScore, 70);
    expect(i.flagged, false);
  });
}
