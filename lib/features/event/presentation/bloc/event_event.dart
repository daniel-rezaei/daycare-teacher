part of 'event_bloc.dart';

sealed class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching all events
class GetAllEventsEvent extends EventEvent {
  const GetAllEventsEvent();
}

