import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Search key for a product image lookup.
String productImageQuery(String brand, String name) => '$brand $name'.trim();

final _imageClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// Resolves a real product image URL from Open Beauty Facts (free, open DB).
/// The cached query is `brand name`; if that finds nothing we retry with just
/// the name (and, as a last resort, the brand) to maximise coverage. Returns
/// null when nothing usable is found — the caller shows the branded gradient
/// fallback. Cached per query, so scrolling back never refetches.
final productImageProvider =
    FutureProvider.family<String?, String>((ref, query) async {
  final q = query.trim();
  if (q.isEmpty) return null;
  final client = ref.read(_imageClientProvider);

  Future<String?> lookup(String terms) async {
    if (terms.trim().isEmpty) return null;
    final uri = Uri.parse('https://world.openbeautyfacts.org/cgi/search.pl')
        .replace(queryParameters: {
      'search_terms': terms,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '1',
      'fields': 'image_front_url,image_url',
    });
    try {
      final res = await client.get(uri, headers: const {
        'User-Agent': 'DermIQ/1.0 (Flutter; contact@dermiq.app)',
      }).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final products = json['products'] as List?;
      if (products == null || products.isEmpty) return null;
      final p = (products.first as Map).cast<String, dynamic>();
      final url = (p['image_front_url'] ?? p['image_url']) as String?;
      return (url != null && url.isNotEmpty) ? url : null;
    } catch (_) {
      return null;
    }
  }

  // Attempt 1: full "brand name". Attempt 2: drop the first word (brand) and
  // search the product name alone, which OBF matches more loosely.
  final full = await lookup(q);
  if (full != null) return full;
  final words = q.split(' ');
  if (words.length > 1) {
    final nameOnly = words.skip(1).join(' ');
    return await lookup(nameOnly);
  }
  return null;
});
