import 'package:intl/intl.dart';

/// App-wide display formatters so currency, ratings, and dates read
/// consistently across every screen.
///
/// Currency + volume-unit output is driven by the user's Settings → Units &
/// Region choices. The active currency/unit is kept in the static fields below,
/// synced from `SettingsNotifier` (see settings_provider.dart) at startup and
/// whenever the user changes the preference.
///
/// NOTE ON CURRENCY: catalog prices are authored as plain amounts (rupee-scale
/// values). Switching currency here changes only the DISPLAYED SYMBOL/format —
/// it does NOT apply any foreign-exchange conversion, so `1299` shows as `$1,299`
/// / `€1,299` / `₹1,299` with the same number. This is deliberate (honest
/// symbol-only display, no faked exchange rates).
class Fmt {
  Fmt._();

  static final NumberFormat _grouped = NumberFormat('#,##0');

  /// The currency symbol currently displayed, mapped from the `currency` pref.
  static String currencySymbol = '₹';

  /// The volume unit currently displayed ('ml' or 'oz'), from the pref.
  static String volumeUnit = 'ml';

  /// Maps a currency code (USD/EUR/GBP/INR) to its symbol.
  static String symbolFor(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
      default:
        return '₹';
    }
  }

  /// Sets the active currency from its code. Called by SettingsNotifier.
  static void setCurrency(String code) => currencySymbol = symbolFor(code);

  /// Sets the active volume unit. Called by SettingsNotifier.
  static void setVolumeUnit(String unit) => volumeUnit = unit;

  /// Price with the active currency symbol, thousands separator, no decimals:
  /// e.g. `₹1,299` / `$1,299`. (Name kept for backwards-compatibility; this is
  /// the app-wide money formatter — see the class note on currency.)
  static String inr(num value) =>
      '$currencySymbol${_grouped.format(value.round())}';

  /// Alias for [inr] with a currency-neutral name.
  static String money(num value) => inr(value);

  /// Rating to a single decimal place: `4.5`.
  static String rating(num value) => value.toStringAsFixed(1);

  /// Standard full date used across orders/appointments: `12 Jun 2026`.
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  /// Formats a volume respecting the active unit preference. Pass both the
  /// millilitre and fluid-ounce values; the matching one is shown.
  static String volume({required num ml, required num flOz}) {
    if (volumeUnit == 'oz') {
      return '${flOz % 1 == 0 ? flOz.toStringAsFixed(0) : flOz} fl oz';
    }
    return '${ml % 1 == 0 ? ml.toStringAsFixed(0) : ml} ml';
  }
}
