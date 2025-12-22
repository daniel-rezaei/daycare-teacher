import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class AttendanceApi {
  final Dio httpclient;
  AttendanceApi(this.httpclient);

  // دریافت attendance بر اساس class_id و child_id
  Future<Response> getAttendanceByClassId({
    required String classId,
    String? childId,
  }) async {
    final queryParams = <String, dynamic>{
      'filter[class_id][_eq]': classId,
      'fields': 'id,check_in_at,check_out_at,child_id,class_id,staff_id,check_in_method,check_out_method,Notes',
      'sort': '-date_created',
    };

    if (childId != null && childId.isNotEmpty) {
      queryParams['filter[child_id][_eq]'] = childId;
    }

    return await httpclient.get(
      '/items/Attendance_Child',
      queryParameters: queryParams,
    );
  }

  // ایجاد attendance جدید
  Future<Response> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  }) async {
    return await httpclient.post(
      '/items/Attendance_Child',
      data: {
        'child_id': childId,
        'class_id': classId,
        'check_in_at': checkInAt,
        'check_out_at': null,
        'staff_id': staffId,
        'check_in_method': 'manually',
      },
    );
  }

  // دریافت attendance بر اساس ID
  Future<Response> getAttendanceById({
    required String attendanceId,
  }) async {
    return await httpclient.get(
      '/items/Attendance_Child/$attendanceId',
      queryParameters: {
        'fields': 'id,check_in_at,check_out_at,child_id,class_id,staff_id,check_in_method,check_out_method,Notes',
      },
    );
  }

  // به‌روزرسانی attendance (برای check out) - استفاده از PATCH
  // مشابه createAttendance: ساده و مستقیم، بدون wrapper و فیلدهای غیرضروری
  Future<Response> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo, // String of file ID (first file ID if multiple)
    String? checkoutPickupContactId,
    String? checkoutPickupContactType,
  }) async {
    debugPrint('[ATTENDANCE_API] ========== updateAttendance called ==========');
    debugPrint('[ATTENDANCE_API] attendanceId: $attendanceId');
    debugPrint('[ATTENDANCE_API] checkOutAt: "$checkOutAt"');
    debugPrint('[ATTENDANCE_API] notes: $notes');
    debugPrint('[ATTENDANCE_API] photo: $photo');
    debugPrint('[ATTENDANCE_API] checkoutPickupContactId: $checkoutPickupContactId');
    debugPrint('[ATTENDANCE_API] checkoutPickupContactType: $checkoutPickupContactType');
    
    // فقط فیلدهای لازم - اگر checkOutAt خالی است، فقط note/photo را به‌روز می‌کنیم
    final data = <String, dynamic>{};
    
    // فقط اگر checkOutAt خالی نباشد، آن را اضافه می‌کنیم
    if (checkOutAt.isNotEmpty) {
      data['check_out_at'] = checkOutAt;
      data['check_out_method'] = 'manually';
    }

    // اضافه کردن فیلدهای اختیاری فقط در صورت وجود
    if (notes != null && notes.isNotEmpty) {
      data['Notes'] = notes; // استفاده از 'Notes' با N بزرگ
    }

    if (photo != null && photo.isNotEmpty) {
      data['photo'] = photo;
    }

    if (checkoutPickupContactId != null && checkoutPickupContactId.isNotEmpty) {
      data['checkout_pickup_contact_id'] = [checkoutPickupContactId];
    }

    // checkout_pickup_contact_type موقتاً حذف شده برای تست
    // if (checkoutPickupContactType != null && checkoutPickupContactType.isNotEmpty) {
    //   data['checkout_pickup_contact_type'] = checkoutPickupContactType;
    // }

    debugPrint('[ATTENDANCE_API] ========== Final Request Body ==========');
    debugPrint('[ATTENDANCE_API] Request URL: /items/Attendance_Child/$attendanceId');
    debugPrint('[ATTENDANCE_API] Request Method: PATCH');
    debugPrint('[ATTENDANCE_API] Request Body (direct, no wrapper): $data');
    
    // PATCH مستقیم بدون wrapper - مشابه createAttendance
    final response = await httpclient.patch(
      '/items/Attendance_Child/$attendanceId',
      data: data,
    );
    
    debugPrint('[ATTENDANCE_API] ========== Response Received ==========');
    debugPrint('[ATTENDANCE_API] Response status: ${response.statusCode}');
    debugPrint('[ATTENDANCE_API] Response data: ${response.data}');
    
    return response;
  }
}

