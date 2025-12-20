import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/notification/domain/repository/notification_repository.dart';

@singleton
class NotificationUsecase {
  final NotificationRepository notificationRepository;

  NotificationUsecase(this.notificationRepository);

  // دریافت لیست همه نوتیفیکیشن‌ها
  Future<DataState<List<NotificationEntity>>> getAllNotifications() async {
    return await notificationRepository.getAllNotifications();
  }
}

