import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/analytics_service.dart';

enum ScanSort { bestMatch, highestRated, nameAZ }

const scanCategories = [
  'All', 'Cleanser', 'Moisturizer', 'Serum', 'Sunscreen', 'Treatment',
];

/// Owns the product-search query, category filter, sort order, and recent-scan
/// history shared by the manual search and search-results screens. Replaces
/// their `_query` / `_filterIdx` / `_sort` `setState` fields.
class ScanState {
  final String query;
  final int categoryIndex;
  final ScanSort sort;
  final List<String> recentScans;

  const ScanState({
    this.query = '',
    this.categoryIndex = 0,
    this.sort = ScanSort.bestMatch,
    this.recentScans = const [],
  });

  ScanState copyWith({
    String? query,
    int? categoryIndex,
    ScanSort? sort,
    List<String>? recentScans,
  }) {
    return ScanState(
      query: query ?? this.query,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      sort: sort ?? this.sort,
      recentScans: recentScans ?? this.recentScans,
    );
  }

  String get category => scanCategories[categoryIndex];
}

class ScanNotifier extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  void setQuery(String query) => state = state.copyWith(query: query);
  void setCategory(int index) => state = state.copyWith(categoryIndex: index);
  void setSort(ScanSort sort) => state = state.copyWith(sort: sort);

  void recordScan(String name) {
    final recent = [name, ...state.recentScans.where((r) => r != name)];
    state = state.copyWith(recentScans: recent.take(10).toList());
    // Analytics — Scanner Usage (no-op until Firebase is configured).
    ref.read(analyticsServiceProvider).logEvent('scanner_used', {'query': name});
  }

  void clearSearch() => state = state.copyWith(query: '', categoryIndex: 0);
}

final scanProvider = NotifierProvider<ScanNotifier, ScanState>(ScanNotifier.new);
