part of 'event_bloc.dart';

sealed class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

final class EventInitial extends EventState {}

/// Loading state for getting all events
final class GetAllEventsLoading extends EventState {}

/// Success state for getting all events
final class GetAllEventsSuccess extends EventState {
  final List<EventEntity> events;

  const GetAllEventsSuccess(this.events);

  @override
  List<Object> get props => [events];
}

/// Failure state for getting all events
final class GetAllEventsFailure extends EventState {
  final String message;

  const GetAllEventsFailure(this.message);

  @override
  List<Object> get props => [message];
}

