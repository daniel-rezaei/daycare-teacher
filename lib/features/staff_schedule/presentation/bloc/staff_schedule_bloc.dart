import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/staff_schedule_entity.dart';
import 'package:teacher_app/features/staff_schedule/domain/usecase/staff_schedule_usecase.dart';

part 'staff_schedule_event.dart';
part 'staff_schedule_state.dart';

@injectable
class StaffScheduleBloc extends Bloc<StaffScheduleEvent, StaffScheduleState> {
  final StaffScheduleUsecase staffScheduleUsecase;
  StaffScheduleBloc(this.staffScheduleUsecase) : super(const StaffScheduleInitial()) {
    on<GetStaffScheduleByStaffIdEvent>(_getStaffScheduleByStaffIdEvent);
  }

  FutureOr<void> _getStaffScheduleByStaffIdEvent(
    GetStaffScheduleByStaffIdEvent event,
    Emitter<StaffScheduleState> emit,
  ) async {
    emit(const GetStaffScheduleByStaffIdLoading());

    try {
      DataState scheduleDataState = await staffScheduleUsecase.getStaffScheduleByStaffId(
        staffId: event.staffId,
      );

      if (scheduleDataState is DataSuccess) {
        final List<StaffScheduleEntity> schedules = scheduleDataState.data!;
        
        // دریافت Shift_Date برای هر schedule
        final List<Map<String, dynamic>> schedulesWithShiftDate = [];
        
        for (var schedule in schedules) {
          if (schedule.shiftDateId != null && schedule.shiftDateId!.isNotEmpty) {
            try {
              DataState shiftDateDataState = await staffScheduleUsecase.getShiftDateById(
                shiftDateId: schedule.shiftDateId!,
              );
              
              if (shiftDateDataState is DataSuccess && shiftDateDataState.data != null) {
                schedulesWithShiftDate.add({
                  'schedule': schedule,
                  'shiftDate': shiftDateDataState.data,
                });
              }
            } catch (e) {
              debugPrint('[STAFF_SCHEDULE_DEBUG] Error fetching shift date ${schedule.shiftDateId}: $e');
              // ادامه به schedule بعدی
            }
          }
        }

        debugPrint(
            '[STAFF_SCHEDULE_DEBUG] GetStaffScheduleByStaffIdSuccess: ${schedulesWithShiftDate.length} items');
        emit(GetStaffScheduleByStaffIdSuccess(schedulesWithShiftDate));
      } else if (scheduleDataState is DataFailed) {
        debugPrint(
            '[STAFF_SCHEDULE_DEBUG] GetStaffScheduleByStaffIdFailure: ${scheduleDataState.error}');
        emit(GetStaffScheduleByStaffIdFailure(scheduleDataState.error!));
      }
    } catch (e) {
      debugPrint('[STAFF_SCHEDULE_DEBUG] Exception getting staff schedule: $e');
      emit(const GetStaffScheduleByStaffIdFailure('خطا در دریافت اطلاعات'));
    }
  }
}

