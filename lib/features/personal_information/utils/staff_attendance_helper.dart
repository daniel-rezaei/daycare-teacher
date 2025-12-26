import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';

class StaffAttendanceHelper {
  StaffAttendanceHelper._();

  /// Get check-in time for a specific date
  static String? getCheckInTime(
    List<StaffAttendanceEntity> attendanceList,
    DateTime selectedDate,
  ) {
    try {
      final checkIn = attendanceList.firstWhere(
        (attendance) =>
            attendance.eventType == 'time_in' &&
            attendance.eventAt != null &&
            DateUtils.isSameDate(attendance.eventAt!, selectedDate),
      );

      if (checkIn.eventAt == null || checkIn.eventAt!.isEmpty) {
        return null;
      }

      // Parse UTC time from API and convert to local for display
      final dateTimeUtc = DateTime.parse(checkIn.eventAt!);
      final dateTimeLocal = dateTimeUtc.toLocal();
      return DateUtils.formatTime(dateTimeLocal.toString());
    } catch (e) {
      return null;
    }
  }

  /// Get check-out time for a specific date
  static String? getCheckOutTime(
    List<StaffAttendanceEntity> attendanceList,
    DateTime selectedDate,
  ) {
    try {
      final checkOut = attendanceList.firstWhere(
        (attendance) =>
            attendance.eventType == 'time_out' &&
            attendance.eventAt != null &&
            DateUtils.isSameDate(attendance.eventAt!, selectedDate),
      );

      if (checkOut.eventAt == null || checkOut.eventAt!.isEmpty) {
        return null;
      }

      // Parse UTC time from API and convert to local for display
      final dateTimeUtc = DateTime.parse(checkOut.eventAt!);
      final dateTimeLocal = dateTimeUtc.toLocal();
      return DateUtils.formatTime(dateTimeLocal.toString());
    } catch (e) {
      return null;
    }
  }
}

