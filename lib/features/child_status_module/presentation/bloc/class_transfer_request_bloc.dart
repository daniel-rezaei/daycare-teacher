import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/usecase/class_transfer_request_usecase.dart';

part 'class_transfer_request_event.dart';
part 'class_transfer_request_state.dart';

@injectable
class ClassTransferRequestBloc
    extends Bloc<ClassTransferRequestEvent, ClassTransferRequestState> {
  final ClassTransferRequestUsecase usecase;

  ClassTransferRequestBloc(this.usecase)
      : super(ClassTransferRequestInitial()) {
    on<CreateTransferRequestEvent>(_createTransferRequestEvent);
    on<UpdateTransferRequestStatusEvent>(_updateTransferRequestStatusEvent);
    on<GetTransferRequestByStudentIdEvent>(_getTransferRequestByStudentIdEvent);
    on<GetTransferRequestsByClassIdEvent>(_getTransferRequestsByClassIdEvent);
  }

  FutureOr<void> _createTransferRequestEvent(
    CreateTransferRequestEvent event,
    Emitter<ClassTransferRequestState> emit,
  ) async {
    emit(CreateTransferRequestLoading());

    try {
      final dataState = await usecase.createTransferRequest(
        childId: event.childId,
        fromClassId: event.fromClassId,
        toClassId: event.toClassId,
        requestedByStaffId: event.requestedByStaffId,
      );

      if (dataState is DataSuccess && dataState.data != null) {
        emit(CreateTransferRequestSuccess(dataState.data!));
      } else if (dataState is DataFailed) {
        emit(CreateTransferRequestFailure(dataState.error!));
      }
    } catch (e) {
      emit(
        const CreateTransferRequestFailure('Error creating transfer request'),
      );
    }
  }

  FutureOr<void> _updateTransferRequestStatusEvent(
    UpdateTransferRequestStatusEvent event,
    Emitter<ClassTransferRequestState> emit,
  ) async {
    emit(UpdateTransferRequestStatusLoading());

    try {
      final dataState = await usecase.updateTransferRequestStatus(
        requestId: event.requestId,
        status: event.status,
      );

      if (dataState is DataSuccess && dataState.data != null) {
        emit(UpdateTransferRequestStatusSuccess(dataState.data!));
      } else if (dataState is DataFailed) {
        emit(UpdateTransferRequestStatusFailure(dataState.error!));
      }
    } catch (e) {
      emit(
        const UpdateTransferRequestStatusFailure(
          'Error updating transfer request',
        ),
      );
    }
  }

  FutureOr<void> _getTransferRequestByStudentIdEvent(
    GetTransferRequestByStudentIdEvent event,
    Emitter<ClassTransferRequestState> emit,
  ) async {
    emit(GetTransferRequestByStudentIdLoading());

    try {
      final dataState = await usecase.getTransferRequestByStudentId(
        studentId: event.studentId,
      );

      if (dataState is DataSuccess) {
        emit(GetTransferRequestByStudentIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        emit(GetTransferRequestByStudentIdFailure(dataState.error!));
      }
    } catch (e) {
      emit(
        const GetTransferRequestByStudentIdFailure(
          'Error retrieving transfer request',
        ),
      );
    }
  }

  FutureOr<void> _getTransferRequestsByClassIdEvent(
    GetTransferRequestsByClassIdEvent event,
    Emitter<ClassTransferRequestState> emit,
  ) async {
    emit(GetTransferRequestsByClassIdLoading());

    try {
      final dataState = await usecase.getTransferRequestsByClassId(
        classId: event.classId,
      );

      if (dataState is DataSuccess) {
        emit(GetTransferRequestsByClassIdSuccess(dataState.data ?? []));
      } else if (dataState is DataFailed) {
        emit(GetTransferRequestsByClassIdFailure(dataState.error!));
      }
    } catch (e) {
      emit(
        const GetTransferRequestsByClassIdFailure(
          'Error retrieving transfer requests',
        ),
      );
    }
  }
}
