class SkinMetric {
  final String name;
  final double score; // 0-100
  final String description;
  final String severity; // 'none', 'mild', 'moderate', 'severe'

  const SkinMetric({
    required this.name,
    required this.score,
    required this.description,
    required this.severity,
  });

  factory SkinMetric.fromMap(Map<String, dynamic> map) => SkinMetric(
        name: map['name'] as String,
        score: (map['score'] as num).toDouble(),
        description: map['description'] as String,
        severity: map['severity'] as String,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'score': score,
        'description': description,
        'severity': severity,
      };
}

class AnalysisModel {
  final String id;
  final String userId;
  final String imageUrl;
  final int overallScore;
  final List<SkinMetric> metrics;
  final List<String> recommendations;
  final DateTime analyzedAt;

  const AnalysisModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.overallScore,
    required this.metrics,
    required this.recommendations,
    required this.analyzedAt,
  });

  SkinMetric? getMetric(String name) =>
      metrics.where((m) => m.name == name).firstOrNull;

  factory AnalysisModel.fromMap(Map<String, dynamic> map) => AnalysisModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        imageUrl: map['imageUrl'] as String,
        overallScore: map['overallScore'] as int,
        metrics: (map['metrics'] as List<dynamic>? ?? [])
            .map((m) => SkinMetric.fromMap(m as Map<String, dynamic>))
            .toList(),
        recommendations: List<String>.from(map['recommendations'] ?? []),
        analyzedAt:
            DateTime.fromMillisecondsSinceEpoch(map['analyzedAt'] as int),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'imageUrl': imageUrl,
        'overallScore': overallScore,
        'metrics': metrics.map((m) => m.toMap()).toList(),
        'recommendations': recommendations,
        'analyzedAt': analyzedAt.millisecondsSinceEpoch,
      };
}
