import 'package:intl/intl.dart';

/// A utility class for formatting numeric values into currency strings.
class CurrencyFormatter {
    /// Internal [NumberFormat] configured for USD currency with 2 decimal places.
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
  );

  /// Formats a [double] amount into a standard currency string.
  /// 
  /// Example: `1234.5` becomes `$1,234.50`.
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Formats a [double] amount into a compact string representation (K/M).
  /// 
  /// Returns a string with 'M' for millions, 'K' for thousands, 
  /// or a standard formatted string for values under 1000.
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
