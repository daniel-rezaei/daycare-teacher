import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/shift_date_entity.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/staff_schedule_entity.dart';
import 'package:teacher_app/features/staff_schedule/domain/repository/staff_schedule_repository.dart';

@singleton
class StaffScheduleUsecase {
  final StaffScheduleRepository staffScheduleRepository;

  StaffScheduleUsecase(this.staffScheduleRepository);

  Future<DataState<List<StaffScheduleEntity>>> getStaffScheduleByStaffId({
    required String staffId,
  }) async {
    return await staffScheduleRepository.getStaffScheduleByStaffId(
      staffId: staffId,
    );
  }

  Future<DataState<ShiftDateEntity>> getShiftDateById({
    required String shiftDateId,
  }) async {
    return await staffScheduleRepository.getShiftDateById(
      shiftDateId: shiftDateId,
    );
  }
}

