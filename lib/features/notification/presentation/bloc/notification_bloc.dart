import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/notification/domain/usecase/notification_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationUsecase notificationUsecase;
  NotificationBloc(this.notificationUsecase) : super(NotificationInitial()) {
    on<GetAllNotificationsEvent>(_getAllNotificationsEvent);
  }

  FutureOr<void> _getAllNotificationsEvent(
    GetAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(GetAllNotificationsLoading());

    try {
      DataState dataState = await notificationUsecase.getAllNotifications();

      if (dataState is DataSuccess) {
        debugPrint(
            '[NOTIFICATION_DEBUG] GetAllNotificationsSuccess: ${dataState.data.length} items');
        emit(GetAllNotificationsSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint('[NOTIFICATION_DEBUG] GetAllNotificationsFailure: ${dataState.error}');
        emit(GetAllNotificationsFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[NOTIFICATION_DEBUG] Exception getting notifications: $e');
      emit(GetAllNotificationsFailure('خطا در دریافت اطلاعات نوتیفیکیشن‌ها'));
    }
  }
}

