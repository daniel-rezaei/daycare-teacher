import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ChildApi {
  final Dio httpclient;
  ChildApi(this.httpclient);

  // دریافت همه بچه‌ها
  Future<Response> getAllChildren() async {
    return await httpclient.get('/items/Child');
  }
}

