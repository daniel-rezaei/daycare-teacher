import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';

abstract class NotificationRepository {
  // دریافت لیست همه نوتیفیکیشن‌ها
  Future<DataState<List<NotificationEntity>>> getAllNotifications();
}

