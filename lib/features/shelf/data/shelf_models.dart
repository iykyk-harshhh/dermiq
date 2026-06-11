// The shelf's product type is now the canonical catalog [Product]. This shim
// keeps the historical `ShelfProduct` / `ExpiryStatus` names working while the
// data lives in the catalog layer (Firestore-backed, seed fallback).
//
// Mock data was removed — the seed now lives in
// `lib/features/catalog/data/catalog_seed.dart` and is served via
// `ProductRepository`.

import '../../catalog/domain/product.dart';

export '../../catalog/domain/product.dart' show Product, ExpiryStatus;

/// Back-compat alias. Prefer [Product] in new code.
typedef ShelfProduct = Product;
