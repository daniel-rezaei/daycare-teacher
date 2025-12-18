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
            'id,Role,staff_id.id,staff_id.contact_id.id,staff_id.contact_id.first_name,staff_id.contact_id.last_name,staff_id.contact_id.email,staff_id.contact_id.photo.id',
      },
    );
  }

  // دریافت class_id بر اساس contact_id
  Future<Response> getClassIdByContactId({required String contactId}) async {
    return await httpclient.get(
      '/items/Staff_Class',
      queryParameters: {
        'filter[staff_id][contact_id][id][_eq]': contactId,
        'fields': 'id,class_id',
        'limit': 1,
      },
    );
  }

  // دریافت contact_id و class_id بر اساس email
  Future<Response> getContactIdAndClassIdByEmail({required String email}) async {
    return await httpclient.get(
      '/items/Staff_Class',
      queryParameters: {
        'filter[staff_id][contact_id][email][_eq]': email,
        'fields': 'id,class_id,staff_id.id,staff_id.contact_id.id',
        'limit': 1,
      },
    );
  }
}
