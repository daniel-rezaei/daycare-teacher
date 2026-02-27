import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/child_management/domain/usecase/class_transfer_request_usecase.dart';
import 'package:teacher_app/features/child_management/utils/child_status_logger.dart';

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
    childStatusLog('TransferBloc: CreateTransferRequest childId=${event.childId} from=${event.fromClassId} to=${event.toClassId}');
    emit(CreateTransferRequestLoading());

    try {
      final dataState = await usecase.createTransferRequest(
        childId: event.childId,
        fromClassId: event.fromClassId,
        toClassId: event.toClassId,
        requestedByStaffId: event.requestedByStaffId,
      );

      if (dataState is DataSuccess && dataState.data != null) {
        childStatusLog('TransferBloc: CreateTransferRequest SUCCESS');
        emit(CreateTransferRequestSuccess(dataState.data!));
      } else if (dataState is DataFailed) {
        childStatusLog('TransferBloc: CreateTransferRequest FAILED ${dataState.error}', isError: true);
        emit(CreateTransferRequestFailure(dataState.error!));
      }
    } catch (e) {
      childStatusLog('TransferBloc: CreateTransferRequest exception $e', isError: true);
      emit(
        const CreateTransferRequestFailure('Error creating transfer request'),
      );
    }
  }

  FutureOr<void> _updateTransferRequestStatusEvent(
    UpdateTransferRequestStatusEvent event,
    Emitter<ClassTransferRequestState> emit,
  ) async {
    childStatusLog('TransferBloc: UpdateTransferStatus requestId=${event.requestId} status=${event.status}');
    emit(UpdateTransferRequestStatusLoading());

    try {
      final dataState = await usecase.updateTransferRequestStatus(
        requestId: event.requestId,
        status: event.status,
      );

      if (dataState is DataSuccess && dataState.data != null) {
        childStatusLog('TransferBloc: UpdateTransferStatus SUCCESS');
        emit(UpdateTransferRequestStatusSuccess(dataState.data!));
      } else if (dataState is DataFailed) {
        childStatusLog('TransferBloc: UpdateTransferStatus FAILED ${dataState.error}', isError: true);
        emit(UpdateTransferRequestStatusFailure(dataState.error!));
      }
    } catch (e) {
      childStatusLog('TransferBloc: UpdateTransferStatus exception $e', isError: true);
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
    childStatusLog('TransferBloc: GetTransferByStudentId studentId=${event.studentId}');
    emit(GetTransferRequestByStudentIdLoading());

    try {
      final dataState = await usecase.getTransferRequestByStudentId(
        studentId: event.studentId,
      );

      if (dataState is DataSuccess) {
        childStatusLog('TransferBloc: GetTransferByStudentId SUCCESS');
        emit(GetTransferRequestByStudentIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        childStatusLog('TransferBloc: GetTransferByStudentId FAILED ${dataState.error}', isError: true);
        emit(GetTransferRequestByStudentIdFailure(dataState.error!));
      }
    } catch (e) {
      childStatusLog('TransferBloc: GetTransferByStudentId exception $e', isError: true);
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
    childStatusLog('TransferBloc: GetTransferRequestsByClassId classId=${event.classId}');
    emit(GetTransferRequestsByClassIdLoading());

    try {
      final dataState = await usecase.getTransferRequestsByClassId(
        classId: event.classId,
      );

      if (dataState is DataSuccess) {
        childStatusLog('TransferBloc: GetTransferRequestsByClassId SUCCESS count=${dataState.data?.length ?? 0}');
        emit(GetTransferRequestsByClassIdSuccess(dataState.data ?? []));
      } else if (dataState is DataFailed) {
        childStatusLog('TransferBloc: GetTransferRequestsByClassId FAILED ${dataState.error}', isError: true);
        emit(GetTransferRequestsByClassIdFailure(dataState.error!));
      }
    } catch (e) {
      childStatusLog('TransferBloc: GetTransferRequestsByClassId exception $e', isError: true);
      emit(
        const GetTransferRequestsByClassIdFailure(
          'Error retrieving transfer requests',
        ),
      );
    }
  }
}
