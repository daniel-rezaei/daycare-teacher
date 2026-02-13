import 'dart:async';
import 'package:equatable/equatable.dart';
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
        emit(GetAttendanceByClassIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        emit(GetAttendanceByClassIdFailure(dataState.error!));
      }
    } catch (e) {
      emit(
        GetAttendanceByClassIdFailure(
          'Error retrieving attendance information',
        ),
      );
    }
  }

  FutureOr<void> _createAttendanceEvent(
    CreateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    // ذخیره کردن state قبلی قبل از emit کردن CreateAttendanceLoading
    final previousState = state;

    emit(CreateAttendanceLoading());

    try {
      DataState dataState = await attendanceUsecase.createAttendance(
        childId: event.childId,
        classId: event.classId,
        checkInAt: event.checkInAt,
        staffId: event.staffId,
      );

      if (dataState is DataSuccess) {
        // اضافه کردن attendance جدید به لیست موجود، بدون دریافت مجدد کل لیست
        // فقط GetAttendanceByClassIdSuccess را emit می‌کنیم تا UI reset نشود
        // Listener ها می‌توانند از GetAttendanceByClassIdSuccess استفاده کنند
        if (previousState is GetAttendanceByClassIdSuccess) {
          final currentState = previousState;
          final updatedList = <AttendanceChildEntity>[
            ...currentState.attendanceList,
            dataState.data,
          ];
          emit(GetAttendanceByClassIdSuccess(updatedList));
        } else {
          // اگر state قبلی GetAttendanceByClassIdSuccess نبود، لیست جدید با یک آیتم ایجاد می‌کنیم
          emit(GetAttendanceByClassIdSuccess([dataState.data]));
        }
      } else if (dataState is DataFailed) {
        emit(CreateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      emit(CreateAttendanceFailure('Error creating attendance'));
    }
  }

  FutureOr<void> _updateAttendanceEvent(
    UpdateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    // ذخیره کردن state قبلی قبل از emit کردن UpdateAttendanceLoading
    final previousState = state;
    emit(const UpdateAttendanceLoading());
    try {
      // DOMAIN LOCKDOWN: Checkout API accepts ONLY pickup_authorization_id
      // No contact/guardian/pickup creation allowed from checkout flow
      DataState dataState = await attendanceUsecase.updateAttendance(
        attendanceId: event.attendanceId,
        checkOutAt: event.checkOutAt,
        notes: event.notes,
        photo: event.photo,
        pickupAuthorizationId: event.pickupAuthorizationId,
        checkoutPickupContactId: event.checkoutPickupContactId,
      );

      if (dataState is DataSuccess) {
        // به‌روزرسانی فقط همان attendance در لیست موجود، بدون دریافت مجدد کل لیست
        // فقط GetAttendanceByClassIdSuccess را emit می‌کنیم تا UI reset نشود
        // Listener ها می‌توانند از GetAttendanceByClassIdSuccess استفاده کنند
        if (previousState is GetAttendanceByClassIdSuccess) {
          final currentState = previousState;
          final updatedList = currentState.attendanceList
              .map<AttendanceChildEntity>((attendance) {
                if (attendance.id == event.attendanceId) {
                  return dataState.data;
                }
                return attendance;
              })
              .toList();
          emit(GetAttendanceByClassIdSuccess(updatedList));
        } else {
          emit(GetAttendanceByClassIdSuccess([dataState.data]));
        }
      } else if (dataState is DataFailed) {
        emit(UpdateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      emit(const UpdateAttendanceFailure('Error updating attendance'));
    }
  }
}
