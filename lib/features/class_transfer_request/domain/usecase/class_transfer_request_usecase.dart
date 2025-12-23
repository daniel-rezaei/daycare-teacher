import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/class_transfer_request/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/class_transfer_request/domain/repository/class_transfer_request_repository.dart';

@singleton
class ClassTransferRequestUsecase {
  final ClassTransferRequestRepository repository;

  ClassTransferRequestUsecase(this.repository);

  /// Create a new class transfer request
  Future<DataState<ClassTransferRequestEntity>> createTransferRequest({
    required String studentId,
    required String fromClassId,
    required String toClassId,
  }) async {
    return await repository.createTransferRequest(
      studentId: studentId,
      fromClassId: fromClassId,
      toClassId: toClassId,
    );
  }

  /// Update transfer request status
  Future<DataState<ClassTransferRequestEntity>> updateTransferRequestStatus({
    required String requestId,
    required String status,
  }) async {
    return await repository.updateTransferRequestStatus(
      requestId: requestId,
      status: status,
    );
  }

  /// Get transfer request by student ID
  Future<DataState<ClassTransferRequestEntity?>> getTransferRequestByStudentId({
    required String studentId,
  }) async {
    return await repository.getTransferRequestByStudentId(
      studentId: studentId,
    );
  }

  /// Get transfer requests by class ID
  Future<DataState<List<ClassTransferRequestEntity>>> getTransferRequestsByClassId({
    required String classId,
  }) async {
    return await repository.getTransferRequestsByClassId(
      classId: classId,
    );
  }
}

