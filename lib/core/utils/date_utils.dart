import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_constants.dart';

class DateUtils {
  DateUtils._();

  /// Get current date and time in ISO 8601 format
  static String getCurrentDateTime() {
    return DateFormat(AppConstants.dateTimeFormat).format(DateTime.now());
  }

  /// Get current date and time in ISO 8601 format with milliseconds and Z (for Check Out)
  /// Format: yyyy-MM-ddTHH:mm:ss.000Z
  static String getCurrentDateTimeForCheckOut() {
    debugPrint('[DATE_UTILS] ========== getCurrentDateTimeForCheckOut called ==========');
    final now = DateTime.now();
    debugPrint('[DATE_UTILS] Local DateTime.now(): $now');
    final nowUtc = now.toUtc();
    debugPrint('[DATE_UTILS] UTC DateTime: $nowUtc');
    final formatted = DateFormat('yyyy-MM-ddTHH:mm:ss').format(nowUtc);
    debugPrint('[DATE_UTILS] Formatted (without .000Z): $formatted');
    final finalResult = '$formatted.000Z';
    debugPrint('[DATE_UTILS] Final result: "$finalResult"');
    debugPrint('[DATE_UTILS] Final result length: ${finalResult.length}');
    return finalResult;
  }

  /// Format date string to display format (MMM d)
  static String formatDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat(AppConstants.displayDateFormat).format(date);
    } catch (e) {
      return '';
    }
  }

  /// Format date string to full display format (MMMM d, yyyy)
  static String formatFullDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat(AppConstants.fullDisplayDateFormat).format(date);
    } catch (e) {
      return '';
    }
  }

  /// Format time string (h:mm)
  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final time = DateTime.parse('2000-01-01 $timeStr');
      return DateFormat(AppConstants.timeFormat).format(time);
    } catch (e) {
      return timeStr;
    }
  }

  /// Get AM/PM from time string
  static String getAmPm(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 'AM';
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      return hour >= 12 ? 'PM' : 'AM';
    } catch (e) {
      return 'AM';
    }
  }

  /// Check if two date strings are on the same date
  static bool isSameDate(String dateTimeStr, DateTime date) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return dateTime.year == date.year &&
          dateTime.month == date.month &&
          dateTime.day == date.day;
    } catch (e) {
      return false;
    }
  }

  /// Get week start (Monday) for a given date
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final daysFromMonday = weekday == 7 ? 0 : weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Get week end (Sunday) for a given date
  static DateTime getWeekEnd(DateTime date) {
    final weekStart = getWeekStart(date);
    return weekStart.add(const Duration(days: 6));
  }
}

