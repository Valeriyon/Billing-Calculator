import 'package:intl/intl.dart';

/// Utility class for generating unique serial numbers
class SerialNumberGenerator {
  SerialNumberGenerator._();

  /// Generate invoice number in format: INV-YYYYMMDD-###
  /// Example: INV-20260126-001
  static String generateInvoiceNumber(DateTime date, int sequence) {
    final dateStr = DateFormat('yyyyMMdd').format(date);
    final seqStr = sequence.toString().padLeft(3, '0');
    return 'INV-$dateStr-$seqStr';
  }

  /// Generate item serial number in format: ITEM-YYYYMMDD-###
  /// Example: ITEM-20260126-001
  static String generateItemSerial(DateTime date, int sequence) {
    final dateStr = DateFormat('yyyyMMdd').format(date);
    final seqStr = sequence.toString().padLeft(3, '0');
    return 'ITEM-$dateStr-$seqStr';
  }

  /// Extract date from invoice number
  static DateTime? extractDateFromInvoiceNumber(String invoiceNo) {
    try {
      // Format: INV-YYYYMMDD-###
      final parts = invoiceNo.split('-');
      if (parts.length >= 2) {
        final dateStr = parts[1];
        return DateFormat('yyyyMMdd').parse(dateStr);
      }
    } catch (_) {
      // Return null if parsing fails
    }
    return null;
  }

  /// Extract sequence number from invoice number
  static int? extractSequenceFromInvoiceNumber(String invoiceNo) {
    try {
      // Format: INV-YYYYMMDD-###
      final parts = invoiceNo.split('-');
      if (parts.length >= 3) {
        return int.parse(parts[2]);
      }
    } catch (_) {
      // Return null if parsing fails
    }
    return null;
  }

  /// Check if invoice number is valid format
  static bool isValidInvoiceNumber(String invoiceNo) {
    final regex = RegExp(r'^INV-\d{8}-\d{3}$');
    return regex.hasMatch(invoiceNo);
  }
}
