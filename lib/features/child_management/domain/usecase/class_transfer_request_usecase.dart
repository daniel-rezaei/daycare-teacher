import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/class_transfer_request_repository.dart';

@singleton
class ClassTransferRequestUsecase {
  final ClassTransferRequestRepository repository;

  ClassTransferRequestUsecase(this.repository);

  Future<DataState<ClassTransferRequestEntity>> createTransferRequest({
    required String childId,
    required String fromClassId,
    required String toClassId,
    required String requestedByStaffId,
  }) async {
    return await repository.createTransferRequest(
      childId: childId,
      fromClassId: fromClassId,
      toClassId: toClassId,
      requestedByStaffId: requestedByStaffId,
    );
  }

  Future<DataState<ClassTransferRequestEntity>> updateTransferRequestStatus({
    required String requestId,
    required String status,
  }) async {
    return await repository.updateTransferRequestStatus(
      requestId: requestId,
      status: status,
    );
  }

  Future<DataState<ClassTransferRequestEntity?>> getTransferRequestByStudentId({
    required String studentId,
  }) async {
    return await repository.getTransferRequestByStudentId(
      studentId: studentId,
    );
  }

  Future<DataState<List<ClassTransferRequestEntity>>>
      getTransferRequestsByClassId({
    required String classId,
  }) async {
    return await repository.getTransferRequestsByClassId(
      classId: classId,
    );
  }
}
