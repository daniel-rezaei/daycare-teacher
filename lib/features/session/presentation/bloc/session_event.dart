part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching session by class_id
class GetSessionByClassIdEvent extends SessionEvent {
  final String classId;

  const GetSessionByClassIdEvent({required this.classId});

  @override
  List<Object> get props => [classId];
}

/// Event for creating a new session (check-in)
class CreateSessionEvent extends SessionEvent {
  final String staffId;
  final String classId;
  final String startAt;

  const CreateSessionEvent({
    required this.staffId,
    required this.classId,
    required this.startAt,
  });

  @override
  List<Object> get props => [staffId, classId, startAt];
}

/// Event for updating an existing session (check-out)
class UpdateSessionEvent extends SessionEvent {
  final String sessionId;
  final String endAt;
  final String classId;

  const UpdateSessionEvent({
    required this.sessionId,
    required this.endAt,
    required this.classId,
  });

  @override
  List<Object> get props => [sessionId, endAt, classId];
}


