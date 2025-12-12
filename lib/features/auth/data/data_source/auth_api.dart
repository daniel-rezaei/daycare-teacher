import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthApi {
  final Dio httpclient;
  AuthApi(this.httpclient);

  // دریافت کلاس ها
  Future<dynamic> classRoom() async {
    final resposne = await httpclient.get('/items/Class');
    return resposne;
  }

  // دریافت کارکنان هر کلاس - پروفایل ها
  Future<dynamic> staffClass() async {
    final resposne = await httpclient.get('/items/Staff_Class');
    return resposne;
  }
}
