import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LocalAbsentStorageService {
  LocalAbsentStorageService._();

  static const String _keyPrefix = 'absent_';
  static const String _dateFormat = 'yyyy-MM-dd';

  static String _getTodayKey(String classId) {
    final today = DateTime.now();
    final dateStr = DateFormat(_dateFormat).format(today);
    return '$_keyPrefix${dateStr}_class_$classId';
  }

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

  static Future<void> markAbsent(String classId, String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey(classId);
    final currentList = prefs.getStringList(key) ?? [];

    if (!currentList.contains(childId)) {
      currentList.add(childId);
      await prefs.setStringList(key, currentList);
    }
  }

  static Future<void> removeAbsent(String classId, String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey(classId);
    final currentList = prefs.getStringList(key) ?? [];

    if (currentList.contains(childId)) {
      currentList.remove(childId);
      await prefs.setStringList(key, currentList);
    }
  }

  static Future<void> clearIfDateChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayDateStr = DateFormat(_dateFormat).format(today);

    final allKeys = prefs.getKeys();
    final absentKeys = allKeys.where((key) => key.startsWith(_keyPrefix));

    for (final key in absentKeys) {
      final withoutPrefix = key.substring(_keyPrefix.length);
      final parts = withoutPrefix.split('_');

      if (parts.isNotEmpty) {
        final keyDateStr = parts[0];
        if (keyDateStr != todayDateStr) {
          await prefs.remove(key);
        }
      }
    }
  }

  static Future<bool> isAbsentToday(String classId, String childId) async {
    final absentSet = await getAbsentToday(classId);
    return absentSet.contains(childId);
  }
}
