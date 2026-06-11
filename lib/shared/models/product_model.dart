class ProductModel {
  final String id;
  final String userId;
  final String name;
  final String brand;
  final String category;
  final String? imageUrl;
  final String? description;
  final List<String> benefits;
  final List<String> ingredients;
  final String? usage;
  final List<String> warnings;
  final DateTime? expiryDate;
  final DateTime addedAt;

  const ProductModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl,
    this.description,
    this.benefits = const [],
    this.ingredients = const [],
    this.usage,
    this.warnings = const [],
    this.expiryDate,
    required this.addedAt,
  });

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool get expiringsSoon =>
      expiryDate != null &&
      !isExpired &&
      expiryDate!.difference(DateTime.now()).inDays <= 30;

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        brand: map['brand'] as String? ?? '',
        category: map['category'] as String,
        imageUrl: map['imageUrl'] as String?,
        description: map['description'] as String?,
        benefits: List<String>.from(map['benefits'] ?? []),
        ingredients: List<String>.from(map['ingredients'] ?? []),
        usage: map['usage'] as String?,
        warnings: List<String>.from(map['warnings'] ?? []),
        expiryDate: map['expiryDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'] as int)
            : null,
        addedAt:
            DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'brand': brand,
        'category': category,
        'imageUrl': imageUrl,
        'description': description,
        'benefits': benefits,
        'ingredients': ingredients,
        'usage': usage,
        'warnings': warnings,
        'expiryDate': expiryDate?.millisecondsSinceEpoch,
        'addedAt': addedAt.millisecondsSinceEpoch,
      };

  static const List<String> categories = [
    'Cleanser',
    'Serum',
    'Moisturizer',
    'Sunscreen',
    'Toner',
    'Eye Cream',
    'Mask',
    'Treatment',
    'Other',
  ];
}
