import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/personal_information/domain/entity/shift_date_entity.dart';
import 'package:teacher_app/features/personal_information/domain/entity/staff_schedule_entity.dart';

class StaffScheduleHelper {
  StaffScheduleHelper._();

  /// Convert day name to index (Monday = 1, Sunday = 7)
  static int dayNameToIndex(String dayName) {
    const dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
      'all': 0,
    };
    return dayMap[dayName] ?? 1;
  }

  /// Convert index to day name
  static String indexToDayName(int index) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayNames[index - 1];
  }

  /// Get date for a specific weekday in a week
  static DateTime getDateForWeekday(DateTime weekStart, int weekday) {
    return weekStart.add(Duration(days: weekday - 1));
  }

  /// Check if schedule overlaps with week
  static bool scheduleOverlapsWeek(
    StaffScheduleEntity schedule,
    DateTime weekStart,
    DateTime weekEnd,
  ) {
    if (schedule.startDate == null || schedule.startDate!.isEmpty) {
      return false;
    }

    try {
      final startDate = DateTime.parse(schedule.startDate!);
      final endDate = schedule.endDate != null && schedule.endDate!.isNotEmpty
          ? DateTime.parse(schedule.endDate!)
          : null;

      final now = DateTime.now();
      
      final isActive = startDate.isBefore(now.add(const Duration(days: 1))) &&
          (endDate == null || endDate.isAfter(now.subtract(const Duration(days: 1))));

      if (!isActive) return false;

      final hasOverlap = startDate.isBefore(weekEnd.add(const Duration(days: 1))) &&
          (endDate == null || endDate.isAfter(weekStart.subtract(const Duration(days: 1))));

      return hasOverlap;
    } catch (e) {
      return false;
    }
  }

  /// Get expanded schedule for current week
  static List<Map<String, dynamic>> getExpandedScheduleForCurrentWeek(
    List<Map<String, dynamic>> schedulesWithShiftDate,
  ) {
    final now = DateTime.now();
    final weekStart = DateUtils.getWeekStart(now);
    final weekEnd = DateUtils.getWeekEnd(now);

    final List<Map<String, dynamic>> expandedSchedules = [];

    for (var item in schedulesWithShiftDate) {
      final schedule = item['schedule'] as StaffScheduleEntity;
      final shiftDate = item['shiftDate'] as ShiftDateEntity;

      if (!scheduleOverlapsWeek(schedule, weekStart, weekEnd)) {
        continue;
      }

      final daysOfWeek = shiftDate.daysOfWeek ?? [];
      if (daysOfWeek.isEmpty) {
        continue;
      }

      DateTime? scheduleStartDate;
      DateTime? scheduleEndDate;

      try {
        if (schedule.startDate != null && schedule.startDate!.isNotEmpty) {
          scheduleStartDate = DateTime.parse(schedule.startDate!);
        }
        if (schedule.endDate != null && schedule.endDate!.isNotEmpty) {
          scheduleEndDate = DateTime.parse(schedule.endDate!);
        }
      } catch (e) {
        continue;
      }

      if (daysOfWeek.contains('all')) {
        for (int weekday = 1; weekday <= 7; weekday++) {
          final actualDate = getDateForWeekday(weekStart, weekday);

          if (scheduleStartDate != null && actualDate.isBefore(scheduleStartDate)) {
            continue;
          }
          if (scheduleEndDate != null && actualDate.isAfter(scheduleEndDate)) {
            continue;
          }
          if (actualDate.isAfter(now)) {
            continue;
          }

          expandedSchedules.add({
            'dayName': indexToDayName(weekday),
            'date': actualDate,
            'startTime': shiftDate.startTime,
            'endTime': shiftDate.endTime,
            'schedule': schedule,
          });
        }
      } else {
        for (var dayName in daysOfWeek) {
          final weekdayIndex = dayNameToIndex(dayName);
          if (weekdayIndex == 0) continue;

          final actualDate = getDateForWeekday(weekStart, weekdayIndex);

          if (scheduleStartDate != null && actualDate.isBefore(scheduleStartDate)) {
            continue;
          }
          if (scheduleEndDate != null && actualDate.isAfter(scheduleEndDate)) {
            continue;
          }
          if (actualDate.isAfter(now)) {
            continue;
          }

          expandedSchedules.add({
            'dayName': indexToDayName(weekdayIndex),
            'date': actualDate,
            'startTime': shiftDate.startTime,
            'endTime': shiftDate.endTime,
            'schedule': schedule,
          });
        }
      }
    }

    expandedSchedules.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });

    return expandedSchedules;
  }
}

