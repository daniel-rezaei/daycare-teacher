import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// Service for managing locally stored absent children for today
///
/// Absent records are stored with a date-based key that automatically
/// becomes invalid when the date changes.
class LocalAbsentStorageService {
  LocalAbsentStorageService._();

  static const String _keyPrefix = 'absent_';
  static const String _dateFormat = 'yyyy-MM-dd';

  /// Get the storage key for today's absent children for a specific class
  static String _getTodayKey(String classId) {
    final today = DateTime.now();
    final dateStr = DateFormat(_dateFormat).format(today);
    return '$_keyPrefix${dateStr}_class_$classId';
  }

  /// Get all absent child IDs for today in a specific class
  static Future<Set<String>> getAbsentToday(String classId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey(classId);
      final absentList = prefs.getStringList(key) ?? [];
      return absentList.toSet();
    } catch (e) {
      return <String>{};
    }
  }

  /// Mark a child as absent for today
  static Future<void> markAbsent(String classId, String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey(classId);
    final currentList = prefs.getStringList(key) ?? [];

    if (!currentList.contains(childId)) {
      currentList.add(childId);
      await prefs.setStringList(key, currentList);
    }
  }

  /// Remove a child from absent list (e.g., when they arrive)
  static Future<void> removeAbsent(String classId, String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey(classId);
    final currentList = prefs.getStringList(key) ?? [];

    if (currentList.contains(childId)) {
      currentList.remove(childId);
      await prefs.setStringList(key, currentList);
    }
  }

  /// Clear all absent records if the date has changed
  /// This should be called on app startup to clean up old data
  static Future<void> clearIfDateChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayDateStr = DateFormat(_dateFormat).format(today);

    // Get all keys that start with the absent prefix
    final allKeys = prefs.getKeys();
    final absentKeys = allKeys.where((key) => key.startsWith(_keyPrefix));

    for (final key in absentKeys) {
      // Extract date from key: absent_YYYY-MM-DD_class_<classId>
      // Remove prefix to get: YYYY-MM-DD_class_<classId>
      final withoutPrefix = key.substring(_keyPrefix.length);
      final parts = withoutPrefix.split('_');

      // parts[0] = YYYY-MM-DD (date), parts[1] = class, parts[2] = classId
      if (parts.isNotEmpty) {
        final keyDateStr = parts[0]; // YYYY-MM-DD

        // If the date in the key doesn't match today, remove it
        if (keyDateStr != todayDateStr) {
          await prefs.remove(key);
        }
      }
    }
  }

  /// Check if a child is marked as absent today
  static Future<bool> isAbsentToday(String classId, String childId) async {
    final absentSet = await getAbsentToday(classId);
    return absentSet.contains(childId);
  }
}
