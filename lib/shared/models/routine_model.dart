class RoutineStep {
  final String id;
  final String productId;
  final String productName;
  final String category;
  final int order;
  bool isCompleted;

  RoutineStep({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.order,
    this.isCompleted = false,
  });

  factory RoutineStep.fromMap(Map<String, dynamic> map) => RoutineStep(
        id: map['id'] as String,
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        category: map['category'] as String,
        order: map['order'] as int,
        isCompleted: map['isCompleted'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'category': category,
        'order': order,
        'isCompleted': isCompleted,
      };

  RoutineStep copyWith({bool? isCompleted}) => RoutineStep(
        id: id,
        productId: productId,
        productName: productName,
        category: category,
        order: order,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

class RoutineModel {
  final String id;
  final String userId;
  final String type; // 'AM' or 'PM'
  final List<RoutineStep> steps;
  final DateTime date;

  const RoutineModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.steps,
    required this.date,
  });

  double get completionRate {
    if (steps.isEmpty) return 0;
    return steps.where((s) => s.isCompleted).length / steps.length;
  }

  factory RoutineModel.fromMap(Map<String, dynamic> map) => RoutineModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        type: map['type'] as String,
        steps: (map['steps'] as List<dynamic>? ?? [])
            .map((s) => RoutineStep.fromMap(s as Map<String, dynamic>))
            .toList(),
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'type': type,
        'steps': steps.map((s) => s.toMap()).toList(),
        'date': date.millisecondsSinceEpoch,
      };
}
