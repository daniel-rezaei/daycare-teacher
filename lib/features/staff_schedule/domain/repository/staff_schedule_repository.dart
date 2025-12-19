import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/shift_date_entity.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/staff_schedule_entity.dart';

abstract class StaffScheduleRepository {
  Future<DataState<List<StaffScheduleEntity>>> getStaffScheduleByStaffId({
    required String staffId,
  });

  Future<DataState<ShiftDateEntity>> getShiftDateById({
    required String shiftDateId,
  });
}

