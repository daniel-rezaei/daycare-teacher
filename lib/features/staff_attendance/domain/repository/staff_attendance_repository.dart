import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';

abstract class StaffAttendanceRepository {
  Future<DataState<List<StaffAttendanceEntity>>> getStaffAttendanceByStaffId({
    required String staffId,
    String? startDate,
    String? endDate,
  });
}

