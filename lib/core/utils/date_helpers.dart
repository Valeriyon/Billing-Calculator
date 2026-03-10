import 'package:intl/intl.dart';

/// Utility class for date operations
class DateHelpers {
  DateHelpers._();

  /// Format date as readable string
  /// Example: 26 Jan 2026
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Format date with time
  /// Example: 26 Jan 2026, 10:30 AM
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, h:mm a').format(date);
  }

  /// Format time only
  /// Example: 10:30 AM
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date for invoice display
  /// Example: 26/01/2026
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date for file export
  /// Example: 20260126
  static String formatDateForFile(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysUntilSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysUntilSunday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get relative date description
  /// Returns "Today", "Yesterday", or formatted date
  static String getRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }

  /// Get date range description
  static String getDateRangeDescription(DateTime start, DateTime end) {
    if (startOfDay(start) == startOfDay(end)) {
      return formatDate(start);
    }
    return '${formatDateShort(start)} - ${formatDateShort(end)}';
  }

  /// Parse date from various formats
  static DateTime? parseDate(String dateStr) {
    final formats = [
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'yyyyMMdd',
      'd MMM yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateStr);
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
