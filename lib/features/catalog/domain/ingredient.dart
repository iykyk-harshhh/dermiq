/// A skincare ingredient in the global catalog. Powers ingredient search and
/// the product analysis (safety scoring + caution flags).
class Ingredient {
  final String id;
  final String name;
  final String inciName; // INCI / scientific name
  final String category; // e.g. 'Humectant', 'Active', 'Surfactant'
  final String function;
  final String description;
  final int safetyScore; // 0–100 (higher = safer)
  final bool comedogenic;
  final bool flagged; // on the caution watchlist
  final List<String> benefits;
  final List<String> concerns;
  final List<String> suitableFor; // skin types

  const Ingredient({
    required this.id,
    required this.name,
    required this.inciName,
    required this.category,
    required this.function,
    required this.description,
    required this.safetyScore,
    this.comedogenic = false,
    this.flagged = false,
    this.benefits = const [],
    this.concerns = const [],
    this.suitableFor = const [],
  });

  /// Normalised key for matching against product ingredient lists.
  String get key => name.toLowerCase().trim();

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'inciName': inciName,
        'category': category,
        'function': function,
        'description': description,
        'safetyScore': safetyScore,
        'comedogenic': comedogenic,
        'flagged': flagged,
        'benefits': benefits,
        'concerns': concerns,
        'suitableFor': suitableFor,
        'searchKey': key, // denormalised for prefix queries
      };

  factory Ingredient.fromFirestore(Map<String, dynamic> data, String id) {
    return Ingredient(
      id: id,
      name: data['name'] as String? ?? '',
      inciName: data['inciName'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      function: data['function'] as String? ?? '',
      description: data['description'] as String? ?? '',
      safetyScore: (data['safetyScore'] as num?)?.toInt() ?? 70,
      comedogenic: data['comedogenic'] as bool? ?? false,
      flagged: data['flagged'] as bool? ?? false,
      benefits: List<String>.from(data['benefits'] ?? const []),
      concerns: List<String>.from(data['concerns'] ?? const []),
      suitableFor: List<String>.from(data['suitableFor'] ?? const []),
    );
  }
}
