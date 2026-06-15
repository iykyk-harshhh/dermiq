import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single detected skin concern with its severity reading.
class SkinConcern {
  final String name;
  final String severity;
  final int percent; // 0–100 prominence
  final Color color;
  final String description;

  const SkinConcern({
    required this.name,
    required this.severity,
    required this.percent,
    required this.color,
    required this.description,
  });
}

/// The outcome of a skin analysis: an overall score (0–100) plus the
/// per-concern breakdown shown on the Analysis Results screen.
class AnalysisResult {
  final int overallScore;
  final List<SkinConcern> concerns;

  const AnalysisResult({required this.overallScore, required this.concerns});

  static const empty = AnalysisResult(overallScore: 0, concerns: []);
}

/// Seed result used until a real scan is processed (or Firestore is wired).
/// `ScanNotifier` should call `setFromScan` once on-device analysis returns.
const _seedResult = AnalysisResult(
  overallScore: 82,
  concerns: [
    SkinConcern(
      name: 'Spots', severity: 'Mild', percent: 25, color: Color(0xFFFF8C6B),
      description: 'Some hyperpigmentation detected on your cheeks.',
    ),
    SkinConcern(
      name: 'Wrinkles', severity: 'Fine', percent: 20, color: Color(0xFF9B82D4),
      description: 'Fine lines around the eye area.',
    ),
    SkinConcern(
      name: 'Texture', severity: 'Moderate', percent: 45, color: Color(0xFFFF9B6B),
      description: 'Uneven texture on T-zone.',
    ),
    SkinConcern(
      name: 'Pores', severity: 'Mild', percent: 30, color: Color(0xFF7B62C4),
      description: 'Slightly enlarged pores on nose.',
    ),
  ],
);

class AnalysisNotifier extends Notifier<AnalysisResult> {
  @override
  AnalysisResult build() => _seedResult;

  /// Replace the current result with the output of a fresh scan.
  void setFromScan(AnalysisResult result) => state = result;
}

final analysisProvider =
    NotifierProvider<AnalysisNotifier, AnalysisResult>(AnalysisNotifier.new);
