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
}

