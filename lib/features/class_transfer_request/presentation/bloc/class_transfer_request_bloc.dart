import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/class_transfer_request/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/class_transfer_request/domain/usecase/class_transfer_request_usecase.dart';

part 'class_transfer_request_event.dart';
part 'class_transfer_request_state.dart';

@injectable
class ClassTransferRequestBloc
    extends Bloc<ClassTransferRequestEvent, ClassTransferRequestState> {
  final ClassTransferRequestUsecase usecase;

  ClassTransferRequestBloc(this.usecase) : super(ClassTransferRequestInitial()) {
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
        studentId: event.studentId,
        fromClassId: event.fromClassId,
        toClassId: event.toClassId,
      );

      if (dataState is DataSuccess && dataState.data != null) {
        debugPrint(
            '[TRANSFER_REQUEST] CreateTransferRequestSuccess: ${dataState.data!.id}');
        emit(CreateTransferRequestSuccess(dataState.data!));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[TRANSFER_REQUEST] CreateTransferRequestFailure: ${dataState.error}');
        emit(CreateTransferRequestFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[TRANSFER_REQUEST] Exception creating transfer request: $e');
      emit(const CreateTransferRequestFailure('خطا در ایجاد درخواست انتقال'));
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
        debugPrint(
            '[TRANSFER_REQUEST] UpdateTransferRequestStatusSuccess: ${dataState.data!.id}');
        emit(UpdateTransferRequestStatusSuccess(dataState.data!));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[TRANSFER_REQUEST] UpdateTransferRequestStatusFailure: ${dataState.error}');
        emit(UpdateTransferRequestStatusFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint(
          '[TRANSFER_REQUEST] Exception updating transfer request: $e');
      emit(const UpdateTransferRequestStatusFailure(
          'خطا در به‌روزرسانی درخواست انتقال'));
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
        debugPrint(
            '[TRANSFER_REQUEST] GetTransferRequestByStudentIdSuccess: ${dataState.data?.id ?? 'null'}');
        emit(GetTransferRequestByStudentIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[TRANSFER_REQUEST] GetTransferRequestByStudentIdFailure: ${dataState.error}');
        emit(GetTransferRequestByStudentIdFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint(
          '[TRANSFER_REQUEST] Exception getting transfer request: $e');
      emit(const GetTransferRequestByStudentIdFailure(
          'خطا در دریافت درخواست انتقال'));
    }
  }

  FutureOr<void> _getTransferRequestsByClassIdEvent(
    GetTransferRequestsByClassIdEvent event,
    Emitter<ClassTransferRequestState> emit,
  ) async {
    debugPrint('[TRANSFER_BLOC] ========== _getTransferRequestsByClassIdEvent START ==========');
    debugPrint('[TRANSFER_BLOC] 📥 Event classId: ${event.classId}');
    debugPrint('[TRANSFER_BLOC] 📊 Current State: ${state.runtimeType}');
    
    emit(GetTransferRequestsByClassIdLoading());
    debugPrint('[TRANSFER_BLOC] 📤 Emitted GetTransferRequestsByClassIdLoading');

    try {
      debugPrint('[TRANSFER_BLOC] 📡 Calling usecase.getTransferRequestsByClassId...');
      final dataState = await usecase.getTransferRequestsByClassId(
        classId: event.classId,
      );

      debugPrint('[TRANSFER_BLOC] ✅ Usecase call completed');
      debugPrint('[TRANSFER_BLOC] 📊 DataState Type: ${dataState.runtimeType}');

      if (dataState is DataSuccess) {
        debugPrint('[TRANSFER_BLOC] ✅ DataState is DataSuccess');
        debugPrint('[TRANSFER_BLOC] 📦 Data: ${dataState.data}');
        debugPrint('[TRANSFER_BLOC] 📦 Data Type: ${dataState.data.runtimeType}');
        
        if (dataState.data != null) {
          debugPrint('[TRANSFER_BLOC] 📊 Data is not null');
          debugPrint('[TRANSFER_BLOC] 📊 Data Length: ${dataState.data!.length}');
          
          if (dataState.data!.isNotEmpty) {
            debugPrint('[TRANSFER_BLOC] 📋 Transfer Requests:');
            for (int i = 0; i < dataState.data!.length; i++) {
              final req = dataState.data![i];
              debugPrint('[TRANSFER_BLOC]   Request $i: id=${req.id}, studentId=${req.studentId}, fromClassId=${req.fromClassId}, toClassId=${req.toClassId}, status=${req.status}');
            }
          } else {
            debugPrint('[TRANSFER_BLOC] ⚠️ Data list is empty');
          }
          
          debugPrint('[TRANSFER_BLOC] 📤 Emitting GetTransferRequestsByClassIdSuccess');
          emit(GetTransferRequestsByClassIdSuccess(dataState.data!));
          debugPrint('[TRANSFER_BLOC] ✅ State emitted successfully');
        } else {
          debugPrint('[TRANSFER_BLOC] ⚠️ Data is null, emitting empty list');
          emit(GetTransferRequestsByClassIdSuccess([]));
        }
      } else if (dataState is DataFailed) {
        debugPrint('[TRANSFER_BLOC] ❌ DataState is DataFailed');
        debugPrint('[TRANSFER_BLOC] 🐛 Error: ${dataState.error}');
        debugPrint('[TRANSFER_BLOC] 📤 Emitting GetTransferRequestsByClassIdFailure');
        emit(GetTransferRequestsByClassIdFailure(dataState.error!));
      } else {
        debugPrint('[TRANSFER_BLOC] ⚠️ Unknown DataState type: ${dataState.runtimeType}');
      }
      
      debugPrint('[TRANSFER_BLOC] ========== _getTransferRequestsByClassIdEvent SUCCESS ==========');
    } catch (e, stackTrace) {
      debugPrint('[TRANSFER_BLOC] ❌ Exception in _getTransferRequestsByClassIdEvent');
      debugPrint('[TRANSFER_BLOC] 🐛 Exception Type: ${e.runtimeType}');
      debugPrint('[TRANSFER_BLOC] 🐛 Exception Message: $e');
      debugPrint('[TRANSFER_BLOC] 📍 Stack Trace:');
      debugPrint('[TRANSFER_BLOC] $stackTrace');
      debugPrint('[TRANSFER_BLOC] 📤 Emitting GetTransferRequestsByClassIdFailure');
      emit(const GetTransferRequestsByClassIdFailure(
          'خطا در دریافت درخواست‌های انتقال'));
      debugPrint('[TRANSFER_BLOC] ========== _getTransferRequestsByClassIdEvent ERROR ==========');
    }
  }
}

