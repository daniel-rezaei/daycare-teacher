import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';
import 'package:teacher_app/features/staff_attendance/domain/usecase/staff_attendance_usecase.dart';

part 'staff_attendance_event.dart';
part 'staff_attendance_state.dart';

@injectable
class StaffAttendanceBloc
    extends Bloc<StaffAttendanceEvent, StaffAttendanceState> {
  final StaffAttendanceUsecase staffAttendanceUsecase;
  StaffAttendanceBloc(this.staffAttendanceUsecase)
      : super(const StaffAttendanceInitial()) {
    on<GetStaffAttendanceByStaffIdEvent>(_getStaffAttendanceByStaffIdEvent);
  }

  FutureOr<void> _getStaffAttendanceByStaffIdEvent(
    GetStaffAttendanceByStaffIdEvent event,
    Emitter<StaffAttendanceState> emit,
  ) async {
    emit(const GetStaffAttendanceByStaffIdLoading());

    try {
      DataState dataState = await staffAttendanceUsecase.getStaffAttendanceByStaffId(
        staffId: event.staffId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      if (dataState is DataSuccess) {
        debugPrint(
            '[STAFF_ATTENDANCE_DEBUG] GetStaffAttendanceByStaffIdSuccess: ${dataState.data?.length} items');
        emit(GetStaffAttendanceByStaffIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[STAFF_ATTENDANCE_DEBUG] GetStaffAttendanceByStaffIdFailure: ${dataState.error}');
        emit(GetStaffAttendanceByStaffIdFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[STAFF_ATTENDANCE_DEBUG] Exception getting staff attendance: $e');
      emit(const GetStaffAttendanceByStaffIdFailure('خطا در دریافت اطلاعات'));
    }
  }
}

