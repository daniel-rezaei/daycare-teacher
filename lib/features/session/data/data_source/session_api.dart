import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class SessionApi {
  final Dio httpclient;
  SessionApi(this.httpclient);

  // دریافت session بر اساس class_id
  Future<Response> getSessionByClassId({required String classId}) async {
    return await httpclient.get(
      '/items/Staff_Class_Session',
      queryParameters: {
        'filter[class_id][_eq]': classId,
        'fields': 'id,start_at,end_at,staff_id,class_id',
        'sort': '-start_at', // جدیدترین session اول
        'limit': 1, // فقط آخرین session
      },
    );
  }

  // ایجاد session جدید (check-in)
  Future<Response> createSession({
    required String staffId,
    required String classId,
    required String startAt,
  }) async {
    return await httpclient.post(
      '/items/Staff_Class_Session',
      data: {
        'staff_id': staffId,
        'class_id': classId,
        'start_at': startAt,
        'end_at': null,
      },
    );
  }

  // به‌روزرسانی session موجود (check-out)
  Future<Response> updateSession({
    required String sessionId,
    required String endAt,
  }) async {
    return await httpclient.patch(
      '/items/Staff_Class_Session/$sessionId',
      data: {
        'end_at': endAt,
      },
    );
  }
}


