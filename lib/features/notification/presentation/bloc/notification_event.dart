part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching all notifications
class GetAllNotificationsEvent extends NotificationEvent {
  const GetAllNotificationsEvent();
}

