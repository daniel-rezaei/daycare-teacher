import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';
import 'package:teacher_app/features/staff_attendance/domain/repository/staff_attendance_repository.dart';

@singleton
class StaffAttendanceUsecase {
  final StaffAttendanceRepository staffAttendanceRepository;

  StaffAttendanceUsecase(this.staffAttendanceRepository);

  Future<DataState<List<StaffAttendanceEntity>>> getStaffAttendanceByStaffId({
    required String staffId,
    String? startDate,
    String? endDate,
  }) async {
    return await staffAttendanceRepository.getStaffAttendanceByStaffId(
      staffId: staffId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// دریافت آخرین رکورد Attendance_Staff برای یک staff
  Future<DataState<StaffAttendanceEntity?>> getLatestStaffAttendance({
    required String staffId,
  }) async {
    return await staffAttendanceRepository.getLatestStaffAttendance(
      staffId: staffId,
    );
  }

  /// ثبت رویداد جدید (time_in یا time_out)
  Future<DataState<StaffAttendanceEntity>> createStaffAttendance({
    required String staffId,
    required String eventType, // 'time_in' or 'time_out'
    required String eventAt, // ISO 8601 format
    String? classId,
  }) async {
    return await staffAttendanceRepository.createStaffAttendance(
      staffId: staffId,
      eventType: eventType,
      eventAt: eventAt,
      classId: classId,
    );
  }
}

