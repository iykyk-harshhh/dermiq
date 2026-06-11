/// Safety classification for a single cosmetic ingredient.
enum IngredientSafety { safe, caution, avoid, unknown }

/// A domain entity: one ingredient parsed from a product's INCI list.
class ScannedIngredient {
  final String name;

  /// What the ingredient does (e.g. "Humectant", "UV filter").
  final String? function;

  final IngredientSafety safety;

  /// Short human-readable note (e.g. "Comedogenic for oily skin").
  final String? note;

  const ScannedIngredient({
    required this.name,
    this.function,
    this.safety = IngredientSafety.unknown,
    this.note,
  });

  ScannedIngredient copyWith({
    String? name,
    String? function,
    IngredientSafety? safety,
    String? note,
  }) =>
      ScannedIngredient(
        name: name ?? this.name,
        function: function ?? this.function,
        safety: safety ?? this.safety,
        note: note ?? this.note,
      );
}
