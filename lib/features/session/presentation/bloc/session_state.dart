part of 'session_bloc.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

/// Loading state for getting session by class_id
final class GetSessionByClassIdLoading extends SessionState {
  const GetSessionByClassIdLoading();
}

/// Success state for getting session by class_id
final class GetSessionByClassIdSuccess extends SessionState {
  final StaffClassSessionEntity? session;

  const GetSessionByClassIdSuccess(this.session);

  @override
  List<Object?> get props => [session];
}

/// Failure state for getting session by class_id
final class GetSessionByClassIdFailure extends SessionState {
  final String message;

  const GetSessionByClassIdFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Loading state for creating session
final class CreateSessionLoading extends SessionState {
  const CreateSessionLoading();
}

/// Success state for creating session
final class CreateSessionSuccess extends SessionState {
  final StaffClassSessionEntity session;

  const CreateSessionSuccess(this.session);

  @override
  List<Object?> get props => [session];
}

/// Failure state for creating session
final class CreateSessionFailure extends SessionState {
  final String message;

  const CreateSessionFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Loading state for updating session
final class UpdateSessionLoading extends SessionState {
  const UpdateSessionLoading();
}

/// Success state for updating session
final class UpdateSessionSuccess extends SessionState {
  final StaffClassSessionEntity session;

  const UpdateSessionSuccess(this.session);

  @override
  List<Object?> get props => [session];
}

/// Failure state for updating session
final class UpdateSessionFailure extends SessionState {
  final String message;

  const UpdateSessionFailure(this.message);

  @override
  List<Object> get props => [message];
}


