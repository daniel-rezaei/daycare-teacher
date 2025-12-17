import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class EventApi {
  final Dio httpclient;
  EventApi(this.httpclient);

  // دریافت لیست همه رویدادها
  Future<Response> getAllEvents() async {
    return await httpclient.get('/items/Events');
  }
}

