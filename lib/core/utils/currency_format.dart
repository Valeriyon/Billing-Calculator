import 'package:intl/intl.dart';

/// Utility class for currency formatting
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Default currency symbol
  static const String defaultSymbol = '₹';

  /// Format amount with currency symbol
  /// Example: ₹1,234.56
  static String format(double amount, {String symbol = defaultSymbol}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
      locale: 'en_IN',
    );
    return formatter.format(amount);
  }

  /// Format amount without currency symbol
  /// Example: 1,234.56
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_IN');
    return formatter.format(amount);
  }

  /// Format amount as compact currency
  /// Example: ₹1.2K, ₹10L
  static String formatCompact(double amount, {String symbol = defaultSymbol}) {
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, symbol: symbol);
  }

  /// Parse currency string to double
  /// Handles strings like "₹1,234.56" or "1234.56"
  static double? parse(String value) {
    try {
      // Remove currency symbols and commas
      final cleaned = value.replaceAll(RegExp(r'[₹$€£,\s]'), '').trim();
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Format for display in calculator (no grouping)
  /// Example: 1234.56
  static String formatForCalculator(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  /// Format quantity (can be integer or decimal)
  static String formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    // Remove trailing zeros
    return qty
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}
