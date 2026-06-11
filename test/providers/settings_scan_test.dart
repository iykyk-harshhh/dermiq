import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dermiq/features/settings/providers/settings_provider.dart';
import 'package:dermiq/features/scan/providers/scan_provider.dart';

void main() {
  group('SettingsNotifier', () {
    test('sensible defaults', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final s = c.read(settingsProvider);
      expect(s.allNotifications, true);
      expect(s.analytics, true);
      expect(s.currency, 'USD');
    });

    test('edit mutates only targeted fields', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(settingsProvider.notifier)
          .edit((s) => s.copyWith(analytics: false, currency: 'EUR'));
      final s = c.read(settingsProvider);
      expect(s.analytics, false);
      expect(s.currency, 'EUR');
      expect(s.personalization, true); // untouched
    });
  });

  group('ScanNotifier', () {
    test('query + category + sort', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(scanProvider.notifier);
      n.setQuery('cera');
      n.setCategory(2);
      n.setSort(ScanSort.highestRated);
      final s = c.read(scanProvider);
      expect(s.query, 'cera');
      expect(s.categoryIndex, 2);
      expect(s.category, scanCategories[2]);
      expect(s.sort, ScanSort.highestRated);
    });

    test('recordScan dedupes and caps history', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(scanProvider.notifier);
      n.recordScan('CeraVe');
      n.recordScan('CeraVe');
      expect(c.read(scanProvider).recentScans, ['CeraVe']);
      for (var i = 0; i < 15; i++) {
        n.recordScan('item$i');
      }
      expect(c.read(scanProvider).recentScans.length, lessThanOrEqualTo(10));
    });

    test('clearSearch resets query + category', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(scanProvider.notifier);
      n.setQuery('x');
      n.setCategory(3);
      n.clearSearch();
      final s = c.read(scanProvider);
      expect(s.query, '');
      expect(s.categoryIndex, 0);
    });
  });
}
