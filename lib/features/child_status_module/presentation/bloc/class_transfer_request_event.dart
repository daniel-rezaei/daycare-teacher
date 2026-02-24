part of 'class_transfer_request_bloc.dart';

abstract class ClassTransferRequestEvent extends Equatable {
  const ClassTransferRequestEvent();

  @override
  List<Object?> get props => [];
}

class CreateTransferRequestEvent extends ClassTransferRequestEvent {
  final String childId;
  final String fromClassId;
  final String toClassId;
  final String requestedByStaffId;

  const CreateTransferRequestEvent({
    required this.childId,
    required this.fromClassId,
    required this.toClassId,
    required this.requestedByStaffId,
  });

  @override
  List<Object?> get props => [childId, fromClassId, toClassId, requestedByStaffId];
}

class UpdateTransferRequestStatusEvent extends ClassTransferRequestEvent {
  final String requestId;
  final String status;

  const UpdateTransferRequestStatusEvent({
    required this.requestId,
    required this.status,
  });

  @override
  List<Object?> get props => [requestId, status];
}

class GetTransferRequestByStudentIdEvent extends ClassTransferRequestEvent {
  final String studentId;

  const GetTransferRequestByStudentIdEvent({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class GetTransferRequestsByClassIdEvent extends ClassTransferRequestEvent {
  final String classId;

  const GetTransferRequestsByClassIdEvent({required this.classId});

  @override
  List<Object?> get props => [classId];
}
