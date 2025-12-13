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

  // دریافت پروفایل‌ها بر اساس کلاس
  Future<Response> staffClass({required String classId}) async {
    return await httpclient.get(
      '/items/Staff_Class',
      queryParameters: {
        'filter[class_id][_eq]': classId,
        'fields':
            'id,Role,staff_id.id,staff_id.contact_id.first_name,staff_id.contact_id.last_name,staff_id.contact_id.email',
      },
    );
  }
}
