import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class NotificationApi {
  final Dio httpclient;
  NotificationApi(this.httpclient);

  // دریافت لیست همه نوتیفیکیشن‌ها
  Future<Response> getAllNotifications() async {
    return await httpclient.get('/items/notifications');
  }
}

