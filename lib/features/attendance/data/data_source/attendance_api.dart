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
      'fields': 'id,check_in_at,check_out_at,child_id,class_id,staff_id,check_in_method,check_out_method',
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
        'fields': 'id,check_in_at,check_out_at,child_id,class_id,staff_id,check_in_method,check_out_method',
      },
    );
  }

  // به‌روزرسانی attendance (برای check out) - استفاده از PATCH
  Future<Response> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo, // String of file ID (first file ID if multiple)
    String? checkoutPickupContactId,
    String? checkoutPickupContactType,
    String? childId,
    String? classId,
    String? checkInAt,
    String? staffId,
    String? checkInMethod,
  }) async {
    // همه فیلدها باید ارسال شوند
    final data = <String, dynamic>{
      'check_out_at': checkOutAt,
      'check_out_method': 'manually',
    };

    // اضافه کردن فیلدهای موجود (همه باید ارسال شوند)
    if (childId != null && childId.isNotEmpty) {
      data['child_id'] = childId;
    }

    if (classId != null && classId.isNotEmpty) {
      data['class_id'] = classId;
    }

    if (checkInAt != null && checkInAt.isNotEmpty) {
      data['check_in_at'] = checkInAt;
    }

    if (staffId != null && staffId.isNotEmpty) {
      data['staff_id'] = staffId;
    }

    if (checkInMethod != null && checkInMethod.isNotEmpty) {
      data['check_in_method'] = checkInMethod;
    }

    if (notes != null && notes.isNotEmpty) {
      data['Notes'] = notes;
    }

    // photo به صورت string ارسال می‌شود
    if (photo != null && photo.isNotEmpty) {
      data['photo'] = photo;
    }

    // checkout_pickup_contact_id به صورت array ارسال می‌شود
    if (checkoutPickupContactId != null && checkoutPickupContactId.isNotEmpty) {
      data['checkout_pickup_contact_id'] = [checkoutPickupContactId];
    }

    if (checkoutPickupContactType != null && checkoutPickupContactType.isNotEmpty) {
      data['checkout_pickup_contact_type'] = checkoutPickupContactType;
    }

    // استفاده از PATCH و ساختار {"data": {...}}
    return await httpclient.patch(
      '/items/Attendance_Child/$attendanceId',
      data: {'data': data},
    );
  }
}

