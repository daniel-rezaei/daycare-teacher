import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child_management/domain/usecase/attendance_usecase.dart';
import 'package:teacher_app/features/child_management/utils/child_status_logger.dart';

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
    childStatusLog('AttendanceBloc: GetAttendanceByClassId classId=${event.classId}');
    emit(GetAttendanceByClassIdLoading());
    try {
      DataState dataState = await attendanceUsecase.getAttendanceByClassId(
        classId: event.classId,
        childId: event.childId,
      );
      if (dataState is DataSuccess) {
        childStatusLog('AttendanceBloc: GetAttendanceByClassId SUCCESS');
        emit(GetAttendanceByClassIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        childStatusLog('AttendanceBloc: GetAttendanceByClassId FAILED ${dataState.error}', isError: true);
        emit(GetAttendanceByClassIdFailure(dataState.error!));
      }
    } catch (e) {
      childStatusLog('AttendanceBloc: GetAttendanceByClassId exception $e', isError: true);
      emit(GetAttendanceByClassIdFailure(
          'Error retrieving attendance information'));
    }
  }

  FutureOr<void> _createAttendanceEvent(
    CreateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    childStatusLog('AttendanceBloc: CreateAttendance childId=${event.childId} classId=${event.classId}');
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
        childStatusLog('AttendanceBloc: CreateAttendance SUCCESS');
        if (previousState is GetAttendanceByClassIdSuccess) {
          final updatedList = <AttendanceChildEntity>[
            ...previousState.attendanceList,
            dataState.data,
          ];
          emit(GetAttendanceByClassIdSuccess(updatedList));
        } else {
          emit(GetAttendanceByClassIdSuccess([dataState.data]));
        }
      } else if (dataState is DataFailed) {
        childStatusLog('AttendanceBloc: CreateAttendance FAILED ${dataState.error}', isError: true);
        emit(CreateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      childStatusLog('AttendanceBloc: CreateAttendance exception $e', isError: true);
      emit(CreateAttendanceFailure('Error creating attendance'));
    }
  }

  FutureOr<void> _updateAttendanceEvent(
    UpdateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    childStatusLog('AttendanceBloc: UpdateAttendance attendanceId=${event.attendanceId}');
    final previousState = state;
    emit(const UpdateAttendanceLoading());
    try {
      DataState dataState = await attendanceUsecase.updateAttendance(
        attendanceId: event.attendanceId,
        checkOutAt: event.checkOutAt,
        notes: event.notes,
        photo: event.photo,
        pickupAuthorizationId: event.pickupAuthorizationId,
        checkoutPickupContactId: event.checkoutPickupContactId,
      );
      if (dataState is DataSuccess) {
        childStatusLog('AttendanceBloc: UpdateAttendance SUCCESS (checkout)');
        if (previousState is GetAttendanceByClassIdSuccess) {
          final updatedList = previousState.attendanceList
              .map<AttendanceChildEntity>((attendance) {
            if (attendance.id == event.attendanceId) return dataState.data;
            return attendance;
          }).toList();
          emit(GetAttendanceByClassIdSuccess(updatedList));
        } else {
          emit(GetAttendanceByClassIdSuccess([dataState.data]));
        }
      } else if (dataState is DataFailed) {
        childStatusLog('AttendanceBloc: UpdateAttendance FAILED ${dataState.error}', isError: true);
        emit(UpdateAttendanceFailure(dataState.error!));
      }
    } catch (e) {
      childStatusLog('AttendanceBloc: UpdateAttendance exception $e', isError: true);
      emit(const UpdateAttendanceFailure('Error updating attendance'));
    }
  }
}
