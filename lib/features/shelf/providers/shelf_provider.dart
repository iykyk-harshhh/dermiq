import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../catalog/data/catalog_seed.dart';
import '../../catalog/data/product_repository.dart';
import '../data/shelf_models.dart';

enum ShelfTab { all, favourites, expiring }

enum ShelfSort { recent, expirySoonest, scoreHighest, nameAZ }

const shelfCategories = [
  'All', 'Cleanser', 'Moisturizer', 'Serum', 'Sunscreen', 'Treatment', 'Toner',
];

/// Owns the user's product shelf plus the active filters. Replaces the
/// `_tab` / `_categoryIdx` / `_query` `setState` fields and the direct
/// `shelfMockProducts` reads scattered across the shelf screens.
class ShelfState {
  final List<ShelfProduct> products;
  final ShelfTab tab;
  final int categoryIndex;
  final String query;
  final ShelfSort sort;

  const ShelfState({
    this.products = const [],
    this.tab = ShelfTab.all,
    this.categoryIndex = 0,
    this.query = '',
    this.sort = ShelfSort.recent,
  });

  ShelfState copyWith({
    List<ShelfProduct>? products,
    ShelfTab? tab,
    int? categoryIndex,
    String? query,
    ShelfSort? sort,
  }) {
    return ShelfState(
      products: products ?? this.products,
      tab: tab ?? this.tab,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      query: query ?? this.query,
      sort: sort ?? this.sort,
    );
  }

  int get expiringCount => products
      .where((p) =>
          p.expiryStatus == ExpiryStatus.expiringSoon ||
          p.expiryStatus == ExpiryStatus.expired)
      .length;

  int get favouritesCount => products.where((p) => p.isFavourite).length;

  /// Products after applying tab + category + search + sort.
  List<ShelfProduct> get filtered {
    final category = shelfCategories[categoryIndex];
    final q = query.trim().toLowerCase();

    var list = products.where((p) {
      final matchesTab = switch (tab) {
        ShelfTab.all => true,
        ShelfTab.favourites => p.isFavourite,
        ShelfTab.expiring => p.expiryStatus != ExpiryStatus.good,
      };
      final matchesCategory = categoryIndex == 0 || p.category == category;
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
      return matchesTab && matchesCategory && matchesQuery;
    }).toList();

    switch (sort) {
      case ShelfSort.recent:
        list.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      case ShelfSort.expirySoonest:
        list.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      case ShelfSort.scoreHighest:
        list.sort((a, b) => b.score.compareTo(a.score));
      case ShelfSort.nameAZ:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }
}

class ShelfNotifier extends Notifier<ShelfState> {
  /// Seeded from the catalog for offline-first; mutations persist to Firestore
  /// (`users/{uid}/shelf`) via [ProductRepository] when signed in.
  @override
  ShelfState build() => ShelfState(products: List.of(catalogProducts));

  ProductRepository get _repo => ref.read(productRepositoryProvider);
  String? get _uid => ref.read(authStateProvider)?.id;

  ShelfProduct? byId(String id) {
    for (final p in state.products) {
      if (p.id == id) return p;
    }
    return null;
  }

  void setTab(ShelfTab tab) => state = state.copyWith(tab: tab);
  void setCategory(int index) => state = state.copyWith(categoryIndex: index);
  void setQuery(String query) => state = state.copyWith(query: query);
  void setSort(ShelfSort sort) => state = state.copyWith(sort: sort);

  void toggleFavourite(String id) {
    state = state.copyWith(products: [
      for (final p in state.products)
        if (p.id == id) p.copyWith(isFavourite: !p.isFavourite) else p,
    ]);
    final uid = _uid;
    final updated = byId(id);
    if (uid != null && updated != null) {
      _repo.setFavourite(uid, id, updated.isFavourite);
    }
  }

  /// Mark a product as used-up (or restock it).
  void setEmpty(String id, bool empty) {
    state = state.copyWith(products: [
      for (final p in state.products)
        if (p.id == id) p.copyWith(isEmpty: empty) else p,
    ]);
    final uid = _uid;
    final updated = byId(id);
    if (uid != null && updated != null) _repo.addToShelf(uid, updated);
  }

  void addProduct(ShelfProduct product) {
    state = state.copyWith(products: [product, ...state.products]);
    final uid = _uid;
    if (uid != null) _repo.addToShelf(uid, product);
  }

  void removeProduct(String id) {
    state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList());
    final uid = _uid;
    if (uid != null) _repo.removeFromShelf(uid, id);
  }
}

final shelfProvider =
    NotifierProvider<ShelfNotifier, ShelfState>(ShelfNotifier.new);
