import '../models/scanned_product_model.dart';

/// Resolves a barcode to product data. Swap the implementation (mock ↔ HTTP)
/// without touching the repository or UI.
abstract interface class ProductRemoteDataSource {
  /// Returns the product, or null if the barcode is unknown.
  /// Throws on transport errors (the repository maps those to [NetworkFailure]).
  Future<ScannedProductModel?> fetchByBarcode(String barcode);
}

/// Offline catalog used until a real product API is wired in. Returns a small
/// set of known barcodes and `null` for everything else.
class MockProductRemoteDataSource implements ProductRemoteDataSource {
  const MockProductRemoteDataSource();

  static const _catalog = <String, ScannedProductModel>{
    '3337875597197': ScannedProductModel(
      barcode: '3337875597197',
      name: 'Hydrating Cleanser',
      brand: 'La Roche-Posay',
      category: 'Cleanser',
      ingredientsText:
          'Aqua, Glycerin, Niacinamide, Ceramide NP, Panthenol, Fragrance',
    ),
    '8901030865278': ScannedProductModel(
      barcode: '8901030865278',
      name: 'Vitamin C Serum',
      brand: 'Minimalist',
      category: 'Serum',
      ingredientsText:
          'Aqua, Sodium Hyaluronate, Tocopherol, Salicylic Acid, Parfum',
    ),
    '0361422090019': ScannedProductModel(
      barcode: '0361422090019',
      name: 'Daily Sunscreen SPF 50',
      brand: 'Neutrogena',
      category: 'Sunscreen',
      ingredientsText:
          'Aqua, Glycerin, Oxybenzone, Squalane, Methylparaben, Fragrance',
    ),
  };

  @override
  Future<ScannedProductModel?> fetchByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate I/O
    return _catalog[barcode];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Reference HTTP implementation (Open Beauty Facts — free, no key).
//  Add `http` to pubspec and swap `productRemoteDataSourceProvider` to use it.
//
//  class OpenBeautyFactsDataSource implements ProductRemoteDataSource {
//    final http.Client client;
//    const OpenBeautyFactsDataSource(this.client);
//
//    @override
//    Future<ScannedProductModel?> fetchByBarcode(String barcode) async {
//      final uri = Uri.parse(
//        'https://world.openbeautyfacts.org/api/v2/product/$barcode.json');
//      final res = await client.get(uri);
//      if (res.statusCode != 200) throw const SocketException('lookup failed');
//      final json = jsonDecode(res.body) as Map<String, dynamic>;
//      if (json['status'] == 0) return null; // not found
//      return ScannedProductModel.fromOpenBeautyFacts(json);
//    }
//  }
// ─────────────────────────────────────────────────────────────────────────────
