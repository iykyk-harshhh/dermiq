import 'package:intl/intl.dart';

/// App-wide display formatters so currency, ratings, and dates read
/// consistently across every screen.
class Fmt {
  Fmt._();

  static final NumberFormat _grouped = NumberFormat('#,##0');

  /// Indian Rupee with a thousands separator and no decimals: `₹1,299`.
  static String inr(num value) => '₹${_grouped.format(value.round())}';

  /// Rating to a single decimal place: `4.5`.
  static String rating(num value) => value.toStringAsFixed(1);

  /// Standard full date used across orders/appointments: `12 Jun 2026`.
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
}
