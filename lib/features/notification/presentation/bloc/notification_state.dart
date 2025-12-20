part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state for getting all notifications
final class GetAllNotificationsLoading extends NotificationState {
  const GetAllNotificationsLoading();
}

/// Success state for getting all notifications
final class GetAllNotificationsSuccess extends NotificationState {
  final List<NotificationEntity> notificationList;

  const GetAllNotificationsSuccess(this.notificationList);

  @override
  List<Object?> get props => [notificationList];
}

/// Failure state for getting all notifications
final class GetAllNotificationsFailure extends NotificationState {
  final String message;

  const GetAllNotificationsFailure(this.message);

  @override
  List<Object> get props => [message];
}

