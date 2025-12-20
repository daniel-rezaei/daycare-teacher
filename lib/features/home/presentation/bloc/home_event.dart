part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

/// Load all home page data
final class LoadHomeDataEvent extends HomeEvent {
  final String? classId;
  final String? contactId;

  const LoadHomeDataEvent({
    this.classId,
    this.contactId,
  });

  @override
  List<Object> get props => [classId ?? '', contactId ?? ''];
}

/// Load class rooms
final class LoadClassRoomsEvent extends HomeEvent {
  const LoadClassRoomsEvent();
}

/// Load contact/profile
final class LoadContactEvent extends HomeEvent {
  final String contactId;

  const LoadContactEvent(this.contactId);

  @override
  List<Object> get props => [contactId];
}

/// Load session by class id
final class LoadSessionEvent extends HomeEvent {
  final String classId;

  const LoadSessionEvent(this.classId);

  @override
  List<Object> get props => [classId];
}

/// Create session (check-in)
final class CreateSessionEvent extends HomeEvent {
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

/// Update session (check-out)
final class UpdateSessionEvent extends HomeEvent {
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

/// Load children
final class LoadChildrenEvent extends HomeEvent {
  const LoadChildrenEvent();
}

/// Load contacts
final class LoadContactsEvent extends HomeEvent {
  const LoadContactsEvent();
}

/// Load dietary restrictions
final class LoadDietaryRestrictionsEvent extends HomeEvent {
  const LoadDietaryRestrictionsEvent();
}

/// Load medications
final class LoadMedicationsEvent extends HomeEvent {
  const LoadMedicationsEvent();
}

/// Load attendance by class id
final class LoadAttendanceEvent extends HomeEvent {
  final String classId;

  const LoadAttendanceEvent(this.classId);

  @override
  List<Object> get props => [classId];
}

/// Load notifications
final class LoadNotificationsEvent extends HomeEvent {
  const LoadNotificationsEvent();
}

/// Load events
final class LoadEventsEvent extends HomeEvent {
  const LoadEventsEvent();
}

