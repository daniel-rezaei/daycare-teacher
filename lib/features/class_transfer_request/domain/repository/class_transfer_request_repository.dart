import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/class_transfer_request/domain/entity/class_transfer_request_entity.dart';

abstract class ClassTransferRequestRepository {
  /// Create a new class transfer request
  Future<DataState<ClassTransferRequestEntity>> createTransferRequest({
    required String childId,
    required String fromClassId,
    required String toClassId,
    required String requestedByStaffId,
  });

  /// Update transfer request status
  Future<DataState<ClassTransferRequestEntity>> updateTransferRequestStatus({
    required String requestId,
    required String status, // 'accepted' or 'declined'
  });

  /// Get transfer request by student ID
  Future<DataState<ClassTransferRequestEntity?>> getTransferRequestByStudentId({
    required String studentId,
  });

  /// Get transfer requests by class ID (for destination class teachers)
  Future<DataState<List<ClassTransferRequestEntity>>> getTransferRequestsByClassId({
    required String classId,
  });
}

