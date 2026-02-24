part of 'class_transfer_request_bloc.dart';

abstract class ClassTransferRequestState extends Equatable {
  const ClassTransferRequestState();

  @override
  List<Object?> get props => [];
}

class ClassTransferRequestInitial extends ClassTransferRequestState {}

class CreateTransferRequestLoading extends ClassTransferRequestState {}

class CreateTransferRequestSuccess extends ClassTransferRequestState {
  final ClassTransferRequestEntity request;

  const CreateTransferRequestSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

class CreateTransferRequestFailure extends ClassTransferRequestState {
  final String message;

  const CreateTransferRequestFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateTransferRequestStatusLoading extends ClassTransferRequestState {}

class UpdateTransferRequestStatusSuccess extends ClassTransferRequestState {
  final ClassTransferRequestEntity request;

  const UpdateTransferRequestStatusSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateTransferRequestStatusFailure extends ClassTransferRequestState {
  final String message;

  const UpdateTransferRequestStatusFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class GetTransferRequestByStudentIdLoading extends ClassTransferRequestState {}

class GetTransferRequestByStudentIdSuccess extends ClassTransferRequestState {
  final ClassTransferRequestEntity? request;

  const GetTransferRequestByStudentIdSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

class GetTransferRequestByStudentIdFailure extends ClassTransferRequestState {
  final String message;

  const GetTransferRequestByStudentIdFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class GetTransferRequestsByClassIdLoading extends ClassTransferRequestState {}

class GetTransferRequestsByClassIdSuccess extends ClassTransferRequestState {
  final List<ClassTransferRequestEntity> requests;

  const GetTransferRequestsByClassIdSuccess(this.requests);

  @override
  List<Object?> get props => [requests];
}

class GetTransferRequestsByClassIdFailure extends ClassTransferRequestState {
  final String message;

  const GetTransferRequestsByClassIdFailure(this.message);

  @override
  List<Object?> get props => [message];
}
