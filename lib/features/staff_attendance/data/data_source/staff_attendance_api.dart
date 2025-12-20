import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class StaffAttendanceApi {
  final Dio httpclient;
  StaffAttendanceApi(this.httpclient);

  // دریافت Attendance_Staff بر اساس staff_id و تاریخ
  Future<Response> getStaffAttendanceByStaffId({
    required String staffId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'filter[staff_id][_eq]': staffId,
      'fields': 'id,staff_id,class_id,event_at,event_type,date_created,date_updated',
      'sort': '-event_at',
    };

    if (startDate != null && startDate.isNotEmpty) {
      queryParams['filter[event_at][_gte]'] = startDate;
    }

    if (endDate != null && endDate.isNotEmpty) {
      queryParams['filter[event_at][_lte]'] = endDate;
    }

    return await httpclient.get(
      '/items/Attendance_Staff',
      queryParameters: queryParams,
    );
  }

  // دریافت آخرین رکورد Attendance_Staff برای یک staff
  Future<Response> getLatestStaffAttendance({
    required String staffId,
  }) async {
    return await httpclient.get(
      '/items/Attendance_Staff',
      queryParameters: {
        'filter[staff_id][_eq]': staffId,
        'fields': 'id,staff_id,class_id,event_at,event_type,date_created,date_updated',
        'sort': '-event_at',
        'limit': 1,
      },
    );
  }

  // ثبت رویداد جدید (time_in یا time_out)
  Future<Response> createStaffAttendance({
    required String staffId,
    required String eventType, // 'time_in' or 'time_out'
    required String eventAt, // ISO 8601 format
    String? classId,
  }) async {
    final data = <String, dynamic>{
      'staff_id': staffId,
      'event_type': eventType,
      'event_at': eventAt,
    };

    if (classId != null && classId.isNotEmpty) {
      data['class_id'] = classId;
    }

    return await httpclient.post(
      '/items/Attendance_Staff',
      data: data,
    );
  }
}

