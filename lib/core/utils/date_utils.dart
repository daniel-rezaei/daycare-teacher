import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_constants.dart';

class DateUtils {
  DateUtils._();

  /// Get current date and time in UTC ISO 8601 format (for API)
  /// Always returns UTC timestamp with Z suffix: yyyy-MM-ddTHH:mm:ss.sssZ
  static String getCurrentDateTime() {
    final localNow = DateTime.now();
    final utcNow = localNow.toUtc();
    final utcIso = utcNow.toIso8601String();
    return utcIso;
  }

  /// Get current date and time in UTC ISO 8601 format (for Check Out)
  /// Always returns UTC timestamp with Z suffix: yyyy-MM-ddTHH:mm:ss.sssZ
  static String getCurrentDateTimeForCheckOut() {
    final localNow = DateTime.now();
    final utcNow = localNow.toUtc();
    final utcIso = utcNow.toIso8601String();
    return utcIso;
  }

  /// Format date string to display format (MMM d)
  /// Converts UTC time from API to local for display
  static String formatDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      // Parse UTC time from API and convert to local for display
      final dateUtc = DateTime.parse(dateStr);
      final dateLocal = dateUtc.toLocal();
      return DateFormat(AppConstants.displayDateFormat).format(dateLocal);
    } catch (e) {
      return '';
    }
  }

  /// Format date string to full display format (MMMM d, yyyy)
  /// Converts UTC time from API to local for display
  static String formatFullDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      // Parse UTC time from API and convert to local for display
      final dateUtc = DateTime.parse(dateStr);
      final dateLocal = dateUtc.toLocal();
      return DateFormat(AppConstants.fullDisplayDateFormat).format(dateLocal);
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
  /// Converts API time (UTC) to local before comparing with local date
  static bool isSameDate(String dateTimeStr, DateTime date) {
    try {
      // Parse API time (assumed UTC) and convert to local
      final apiTime = DateTime.parse(dateTimeStr);
      final apiTimeLocal = apiTime.toLocal();
      // Compare with local date (date is already in local timezone)
      return apiTimeLocal.year == date.year &&
          apiTimeLocal.month == date.month &&
          apiTimeLocal.day == date.day;
    } catch (e) {
      return false;
    }
  }

  /// Convert ISO 8601 string from API (UTC) to local DateTime
  static DateTime toLocalTime(String iso) {
    return DateTime.parse(iso).toLocal();
  }

  /// Get current UTC time as ISO 8601 string
  static String nowUtcIso() {
    return DateTime.now().toUtc().toIso8601String();
  }

  /// Check if two DateTime objects are on the same local day
  static bool isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
