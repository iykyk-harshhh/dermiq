import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dermiq/features/scanner/data/datasources/product_remote_data_source.dart';

const _okBody = '''
{
  "code": "1234567890123",
  "status": 1,
  "product": {
    "product_name": "Soothing Serum",
    "brands": "GlowLab, OtherBrand",
    "categories": "Cosmetics, Serums",
    "image_url": "https://img.example/serum.jpg",
    "ingredients_text": "Aqua, Niacinamide, Glycerin"
  }
}
''';

void main() {
  test('parses an Open Beauty Facts hit', () async {
    final client = MockClient((req) async => http.Response(_okBody, 200));
    final ds = OpenBeautyFactsDataSource(client);
    final p = await ds.fetchByBarcode('1234567890123');
    expect(p, isNotNull);
    expect(p!.name, 'Soothing Serum');
    expect(p.brand, 'GlowLab'); // first brand only
    expect(p.category, 'Serums'); // last category
    expect(p.ingredientsText, contains('Niacinamide'));
  });

  test('falls back to the offline catalog on 404', () async {
    final client = MockClient((req) async => http.Response('{}', 404));
    final ds = OpenBeautyFactsDataSource(client,
        fallback: const MockProductRemoteDataSource());
    // A known demo barcode resolves via the fallback.
    final p = await ds.fetchByBarcode('3337875597197');
    expect(p, isNotNull);
    expect(p!.brand, 'La Roche-Posay');
  });

  test('falls back on network error, else rethrows', () async {
    final client = MockClient((req) async => throw Exception('offline'));
    final ds = OpenBeautyFactsDataSource(client,
        fallback: const MockProductRemoteDataSource());
    // Known barcode → fallback resolves it despite the network error.
    expect(await ds.fetchByBarcode('8901030865278'), isNotNull);
    // Unknown barcode → no fallback hit → error propagates.
    expect(ds.fetchByBarcode('0000000000000'), throwsA(isA<Exception>()));
  });

  test('status:0 (not found) returns null with no fallback', () async {
    final client =
        MockClient((req) async => http.Response('{"status":0}', 200));
    final ds = OpenBeautyFactsDataSource(client);
    expect(await ds.fetchByBarcode('9999999999999'), isNull);
  });
}
