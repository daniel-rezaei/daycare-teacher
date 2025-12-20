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
    on<GetLatestStaffAttendanceEvent>(_getLatestStaffAttendanceEvent);
    on<CreateStaffAttendanceEvent>(_createStaffAttendanceEvent);
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

  FutureOr<void> _getLatestStaffAttendanceEvent(
    GetLatestStaffAttendanceEvent event,
    Emitter<StaffAttendanceState> emit,
  ) async {
    emit(const GetLatestStaffAttendanceLoading());

    try {
      DataState dataState = await staffAttendanceUsecase.getLatestStaffAttendance(
        staffId: event.staffId,
      );

      if (dataState is DataSuccess) {
        debugPrint(
            '[STAFF_ATTENDANCE_DEBUG] GetLatestStaffAttendanceSuccess: ${dataState.data?.id ?? 'null'}');
        emit(GetLatestStaffAttendanceSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[STAFF_ATTENDANCE_DEBUG] GetLatestStaffAttendanceFailure: ${dataState.error}');
        emit(GetLatestStaffAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[STAFF_ATTENDANCE_DEBUG] Exception getting latest staff attendance: $e');
      emit(const GetLatestStaffAttendanceFailure('خطا در دریافت اطلاعات'));
    }
  }

  FutureOr<void> _createStaffAttendanceEvent(
    CreateStaffAttendanceEvent event,
    Emitter<StaffAttendanceState> emit,
  ) async {
    emit(const CreateStaffAttendanceLoading());

    try {
      // تبدیل DateTime.now() به ISO 8601 format
      final now = DateTime.now().toUtc();
      final eventAt = now.toIso8601String();

      DataState dataState = await staffAttendanceUsecase.createStaffAttendance(
        staffId: event.staffId,
        eventType: event.eventType,
        eventAt: eventAt,
        classId: event.classId,
      );

      if (dataState is DataSuccess) {
        debugPrint(
            '[STAFF_ATTENDANCE_DEBUG] CreateStaffAttendanceSuccess: ${dataState.data.id}');
        emit(CreateStaffAttendanceSuccess(dataState.data));
        
        // بعد از ثبت موفق، آخرین رکورد را دوباره دریافت کن
        add(GetLatestStaffAttendanceEvent(staffId: event.staffId));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[STAFF_ATTENDANCE_DEBUG] CreateStaffAttendanceFailure: ${dataState.error}');
        emit(CreateStaffAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[STAFF_ATTENDANCE_DEBUG] Exception creating staff attendance: $e');
      emit(const CreateStaffAttendanceFailure('خطا در ثبت اطلاعات'));
    }
  }
}

