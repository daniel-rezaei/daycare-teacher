import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/attendance/domain/usecase/attendance_usecase.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

@injectable
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceUsecase attendanceUsecase;
  AttendanceBloc(this.attendanceUsecase) : super(AttendanceInitial()) {
    on<GetAttendanceByClassIdEvent>(_getAttendanceByClassIdEvent);
    on<CreateAttendanceEvent>(_createAttendanceEvent);
    on<UpdateAttendanceEvent>(_updateAttendanceEvent);
  }

  FutureOr<void> _getAttendanceByClassIdEvent(
    GetAttendanceByClassIdEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(GetAttendanceByClassIdLoading());

    try {
      DataState dataState = await attendanceUsecase.getAttendanceByClassId(
        classId: event.classId,
        childId: event.childId,
      );

      if (dataState is DataSuccess) {
        debugPrint(
            '[ATTENDANCE_DEBUG] GetAttendanceByClassIdSuccess: ${dataState.data.length} items');
        emit(GetAttendanceByClassIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint('[ATTENDANCE_DEBUG] GetAttendanceByClassIdFailure: ${dataState.error}');
        emit(GetAttendanceByClassIdFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[ATTENDANCE_DEBUG] Exception getting attendance: $e');
      emit(GetAttendanceByClassIdFailure('خطا در دریافت اطلاعات attendance'));
    }
  }

  FutureOr<void> _createAttendanceEvent(
    CreateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(CreateAttendanceLoading());

    try {
      DataState dataState = await attendanceUsecase.createAttendance(
        childId: event.childId,
        classId: event.classId,
        checkInAt: event.checkInAt,
        staffId: event.staffId,
      );

      if (dataState is DataSuccess) {
        debugPrint('[ATTENDANCE_DEBUG] CreateAttendanceSuccess: ${dataState.data.id}');
        
        // اضافه کردن attendance جدید به لیست موجود، بدون دریافت مجدد کل لیست
        if (state is GetAttendanceByClassIdSuccess) {
          final currentState = state as GetAttendanceByClassIdSuccess;
          final updatedList = <AttendanceChildEntity>[...currentState.attendanceList, dataState.data];
          emit(GetAttendanceByClassIdSuccess(updatedList));
        } else {
          // اگر state قبلی GetAttendanceByClassIdSuccess نبود، فقط success را emit می‌کنیم
          emit(CreateAttendanceSuccess(dataState.data));
        }
      } else if (dataState is DataFailed) {
        debugPrint('[ATTENDANCE_DEBUG] CreateAttendanceFailure: ${dataState.error}');
        emit(CreateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[ATTENDANCE_DEBUG] Exception creating attendance: $e');
      emit(CreateAttendanceFailure('خطا در ایجاد attendance'));
    }
  }

  FutureOr<void> _updateAttendanceEvent(
    UpdateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    debugPrint('[ATTENDANCE_BLOC] ========== _updateAttendanceEvent called ==========');
    debugPrint('[ATTENDANCE_BLOC] event.attendanceId: ${event.attendanceId}');
    debugPrint('[ATTENDANCE_BLOC] event.checkOutAt: "${event.checkOutAt}"');
    debugPrint('[ATTENDANCE_BLOC] event.checkOutAt type: ${event.checkOutAt.runtimeType}');
    debugPrint('[ATTENDANCE_BLOC] event.checkOutAt isEmpty: ${event.checkOutAt.isEmpty}');
    debugPrint('[ATTENDANCE_BLOC] event.notes: ${event.notes}');
    debugPrint('[ATTENDANCE_BLOC] event.photo: ${event.photo}');
    debugPrint('[ATTENDANCE_BLOC] event.checkoutPickupContactId: ${event.checkoutPickupContactId}');
    debugPrint('[ATTENDANCE_BLOC] event.checkoutPickupContactType: ${event.checkoutPickupContactType}');
    
    emit(const UpdateAttendanceLoading());

    try {
      debugPrint('[ATTENDANCE_BLOC] Calling attendanceUsecase.updateAttendance...');
      debugPrint('[ATTENDANCE_BLOC] Passing checkOutAt: "${event.checkOutAt}"');
      DataState dataState = await attendanceUsecase.updateAttendance(
        attendanceId: event.attendanceId,
        checkOutAt: event.checkOutAt,
        notes: event.notes,
        photo: event.photo, // List<String>?
        checkoutPickupContactId: event.checkoutPickupContactId,
        checkoutPickupContactType: event.checkoutPickupContactType,
      );

      if (dataState is DataSuccess) {
        debugPrint('[ATTENDANCE_DEBUG] UpdateAttendanceSuccess: ${dataState.data.id}');
        
        // به‌روزرسانی فقط همان attendance در لیست موجود، بدون دریافت مجدد کل لیست
        if (state is GetAttendanceByClassIdSuccess) {
          final currentState = state as GetAttendanceByClassIdSuccess;
          final updatedList = currentState.attendanceList.map<AttendanceChildEntity>((attendance) {
            if (attendance.id == event.attendanceId) {
              return dataState.data;
            }
            return attendance;
          }).toList();
          
          // emit کردن GetAttendanceByClassIdSuccess برای به‌روزرسانی لیست
          emit(GetAttendanceByClassIdSuccess(updatedList));
          // emit کردن UpdateAttendanceSuccess برای اطلاع CheckOutWidget
          emit(UpdateAttendanceSuccess(dataState.data));
        } else {
          // اگر state قبلی GetAttendanceByClassIdSuccess نبود، فقط success را emit می‌کنیم
          emit(UpdateAttendanceSuccess(dataState.data));
        }
      } else if (dataState is DataFailed) {
        debugPrint('[ATTENDANCE_DEBUG] UpdateAttendanceFailure: ${dataState.error}');
        emit(UpdateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[ATTENDANCE_DEBUG] Exception updating attendance: $e');
      emit(const UpdateAttendanceFailure('خطا در به‌روزرسانی attendance'));
    }
  }
}

