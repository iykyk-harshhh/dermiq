import 'dart:convert';

import 'package:http/http.dart' as http;

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
//  Live implementation — Open Beauty Facts (free, no API key required).
//  A global cosmetics database keyed by barcode.
// ─────────────────────────────────────────────────────────────────────────────

class OpenBeautyFactsDataSource implements ProductRemoteDataSource {
  OpenBeautyFactsDataSource(this._client, {this.fallback});

  final http.Client _client;

  /// Optional offline catalog consulted when the network lookup fails or the
  /// barcode isn't in the database (keeps demo barcodes resolvable offline).
  final ProductRemoteDataSource? fallback;

  static const _base = 'https://world.openbeautyfacts.org/api/v2/product';

  @override
  Future<ScannedProductModel?> fetchByBarcode(String barcode) async {
    final code = barcode.trim();
    if (code.isEmpty) return null;
    try {
      final uri = Uri.parse(
          '$_base/$code.json?fields=code,product_name,brands,categories,'
          'image_url,ingredients_text');
      final res = await _client.get(uri, headers: const {
        // Open Beauty Facts asks clients to identify themselves.
        'User-Agent': 'DermIQ/1.0 (Flutter; contact@dermiq.app)',
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 404) return await _fallback(code);
      if (res.statusCode != 200) {
        throw Exception('Open Beauty Facts lookup failed (${res.statusCode})');
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['status'] == 0 || json['product'] == null) {
        return await _fallback(code); // not found in the database
      }
      return ScannedProductModel.fromOpenBeautyFacts(json);
    } catch (e) {
      // Network/parse error — try the offline catalog before giving up.
      final cached = await _fallback(code);
      if (cached != null) return cached;
      rethrow; // repository maps this to a NetworkFailure
    }
  }

  Future<ScannedProductModel?> _fallback(String code) =>
      fallback?.fetchByBarcode(code) ?? Future.value(null);
}
