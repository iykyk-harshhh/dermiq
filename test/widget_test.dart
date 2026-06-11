// The full-app smoke test (pumping DermIQApp) is intentionally omitted here:
// the splash screen schedules a navigation Timer + continuous animations and
// loads Google Fonts, which makes a top-level pump flaky under flutter_test.
//
// Coverage is provided instead by focused suites:
//   • widgets/shared_widgets_test.dart   — shared UI components
//   • providers/*                        — state notifiers & controllers
//   • catalog/*                          — models, repositories, analysis
//   • router/navigation_test.dart        — route constants + auth guard
//   • calendar/calendar_models_test.dart — date/streak helpers

import 'package:flutter_test/flutter_test.dart';
import 'package:dermiq/features/catalog/domain/product_analysis.dart';

void main() {
  test('ProductAnalysis verdict thresholds', () {
    expect(const ProductAnalysis(overallScore: 90, matched: [], flagged: [], unknown: [])
        .verdict, 'Excellent');
    expect(const ProductAnalysis(overallScore: 75, matched: [], flagged: [], unknown: [])
        .verdict, 'Good');
    expect(const ProductAnalysis(overallScore: 55, matched: [], flagged: [], unknown: [])
        .verdict, 'Fair');
    expect(const ProductAnalysis(overallScore: 20, matched: [], flagged: [], unknown: [])
        .verdict, 'Use with caution');
    expect(ProductAnalysis.empty.isClean, isTrue);
  });
}
