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

  // دریافت لیست همه محدودیت‌های غذایی
  Future<Response> getAllDietaryRestrictions() async {
    return await httpclient.get('/items/Child_Dietary_Restrictions');
  }

  // دریافت لیست همه داروها
  Future<Response> getAllMedications() async {
    return await httpclient.get('/items/Medication');
  }
}

