import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/class_transfer_request_entity.dart';

abstract class ClassTransferRequestRepository {
  Future<DataState<ClassTransferRequestEntity>> createTransferRequest({
    required String childId,
    required String fromClassId,
    required String toClassId,
    required String requestedByStaffId,
  });

  Future<DataState<ClassTransferRequestEntity>> updateTransferRequestStatus({
    required String requestId,
    required String status,
  });

  Future<DataState<ClassTransferRequestEntity?>> getTransferRequestByStudentId({
    required String studentId,
  });

  Future<DataState<List<ClassTransferRequestEntity>>>
      getTransferRequestsByClassId({
    required String classId,
  });
}
