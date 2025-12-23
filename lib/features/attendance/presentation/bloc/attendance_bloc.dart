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
      emit(GetAttendanceByClassIdFailure('Error retrieving attendance information'));
    }
  }

  FutureOr<void> _createAttendanceEvent(
    CreateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    // ذخیره کردن state قبلی قبل از emit کردن CreateAttendanceLoading
    final previousState = state;
    debugPrint('[ATTENDANCE_BLOC] 📋 Previous state before loading: ${previousState.runtimeType}');
    
    emit(CreateAttendanceLoading());

    try {
      DataState dataState = await attendanceUsecase.createAttendance(
        childId: event.childId,
        classId: event.classId,
        checkInAt: event.checkInAt,
        staffId: event.staffId,
      );

      if (dataState is DataSuccess) {
        debugPrint('[ATTENDANCE_BLOC] ✅ CreateAttendanceSuccess: ${dataState.data.id}');
        debugPrint('[ATTENDANCE_BLOC] 📋 Previous state (saved): ${previousState.runtimeType}');
        
        // اضافه کردن attendance جدید به لیست موجود، بدون دریافت مجدد کل لیست
        // فقط GetAttendanceByClassIdSuccess را emit می‌کنیم تا UI reset نشود
        // Listener ها می‌توانند از GetAttendanceByClassIdSuccess استفاده کنند
        if (previousState is GetAttendanceByClassIdSuccess) {
          final currentState = previousState;
          debugPrint('[ATTENDANCE_BLOC] 📋 Previous list length: ${currentState.attendanceList.length}');
          final updatedList = <AttendanceChildEntity>[...currentState.attendanceList, dataState.data];
          debugPrint('[ATTENDANCE_BLOC] 📋 New list length: ${updatedList.length}');
          debugPrint('[ATTENDANCE_BLOC] 📋 New attendance: id=${dataState.data.id}, childId=${dataState.data.childId}, checkIn=${dataState.data.checkInAt}, checkOut=${dataState.data.checkOutAt}');
          emit(GetAttendanceByClassIdSuccess(updatedList));
        } else {
          // اگر state قبلی GetAttendanceByClassIdSuccess نبود، لیست جدید با یک آیتم ایجاد می‌کنیم
          debugPrint('[ATTENDANCE_BLOC] ⚠️ Previous state was not GetAttendanceByClassIdSuccess, creating new list');
          emit(GetAttendanceByClassIdSuccess([dataState.data]));
        }
      } else if (dataState is DataFailed) {
        debugPrint('[ATTENDANCE_DEBUG] CreateAttendanceFailure: ${dataState.error}');
        emit(CreateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[ATTENDANCE_DEBUG] Exception creating attendance: $e');
      emit(CreateAttendanceFailure('Error creating attendance'));
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
    
    // ذخیره کردن state قبلی قبل از emit کردن UpdateAttendanceLoading
    final previousState = state;
    debugPrint('[ATTENDANCE_BLOC] 📋 Previous state before loading: ${previousState.runtimeType}');
    
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
        debugPrint('[ATTENDANCE_BLOC] ✅ UpdateAttendanceSuccess: ${dataState.data.id}');
        debugPrint('[ATTENDANCE_BLOC] 📋 Previous state (saved): ${previousState.runtimeType}');
        
        // به‌روزرسانی فقط همان attendance در لیست موجود، بدون دریافت مجدد کل لیست
        // فقط GetAttendanceByClassIdSuccess را emit می‌کنیم تا UI reset نشود
        // Listener ها می‌توانند از GetAttendanceByClassIdSuccess استفاده کنند
        if (previousState is GetAttendanceByClassIdSuccess) {
          final currentState = previousState;
          debugPrint('[ATTENDANCE_BLOC] 📋 Previous list length: ${currentState.attendanceList.length}');
          debugPrint('[ATTENDANCE_BLOC] 📋 Updating attendanceId: ${event.attendanceId}');
          final updatedList = currentState.attendanceList.map<AttendanceChildEntity>((attendance) {
            if (attendance.id == event.attendanceId) {
              debugPrint('[ATTENDANCE_BLOC] 📋 Found matching attendance: ${attendance.id}, updating...');
              return dataState.data;
            }
            return attendance;
          }).toList();
          
          debugPrint('[ATTENDANCE_BLOC] 📋 Updated list length: ${updatedList.length}');
          debugPrint('[ATTENDANCE_BLOC] 📋 Updated attendance: id=${dataState.data.id}, childId=${dataState.data.childId}, checkIn=${dataState.data.checkInAt}, checkOut=${dataState.data.checkOutAt}');
          emit(GetAttendanceByClassIdSuccess(updatedList));
        } else {
          // اگر state قبلی GetAttendanceByClassIdSuccess نبود، لیست جدید با یک آیتم ایجاد می‌کنیم
          debugPrint('[ATTENDANCE_BLOC] ⚠️ Previous state was not GetAttendanceByClassIdSuccess, creating new list');
          emit(GetAttendanceByClassIdSuccess([dataState.data]));
        }
      } else if (dataState is DataFailed) {
        debugPrint('[ATTENDANCE_DEBUG] UpdateAttendanceFailure: ${dataState.error}');
        emit(UpdateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[ATTENDANCE_DEBUG] Exception updating attendance: $e');
      emit(const UpdateAttendanceFailure('Error updating attendance'));
    }
  }
}

