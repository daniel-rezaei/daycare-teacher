import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';

abstract class StaffAttendanceRepository {
  Future<DataState<List<StaffAttendanceEntity>>> getStaffAttendanceByStaffId({
    required String staffId,
    String? startDate,
    String? endDate,
  });

  /// دریافت آخرین رکورد Attendance_Staff برای یک staff
  Future<DataState<StaffAttendanceEntity?>> getLatestStaffAttendance({
    required String staffId,
  });

  /// ثبت رویداد جدید (time_in یا time_out)
  Future<DataState<StaffAttendanceEntity>> createStaffAttendance({
    required String staffId,
    required String eventType, // 'time_in' or 'time_out'
    required String eventAt, // ISO 8601 format
    String? classId,
  });
}

