import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class AttendanceApi {
  final Dio httpclient;
  AttendanceApi(this.httpclient);

  Future<Response> getAttendanceByClassId({
    required String classId,
    String? childId,
  }) async {
    final queryParams = <String, dynamic>{
      'filter[class_id][_eq]': classId,
      'fields':
          'id,check_in_at,check_out_at,child_id,class_id,staff_id,check_in_method,check_out_method,Notes',
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

  Future<Response> getAttendanceById({required String attendanceId}) async {
    return await httpclient.get(
      '/items/Attendance_Child/$attendanceId',
      queryParameters: {
        'fields':
            'id,check_in_at,check_out_at,child_id,class_id,staff_id,check_in_method,check_out_method,Notes',
      },
    );
  }

  Future<Response> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo,
    String? pickupAuthorizationId,
    String? checkoutPickupContactId,
  }) async {
    final data = <String, dynamic>{};
    if (checkOutAt.isNotEmpty) {
      data['check_out_at'] = checkOutAt;
      data['check_out_method'] = 'manually';
    }
    if (notes != null && notes.isNotEmpty) data['Notes'] = notes;
    if (photo != null && photo.isNotEmpty) data['photo'] = photo;
    if (pickupAuthorizationId != null && pickupAuthorizationId.isNotEmpty) {
      data['pickup_authorization_id'] = pickupAuthorizationId;
    }
    if (checkoutPickupContactId != null && checkoutPickupContactId.isNotEmpty) {
      data['checkout_pickup_contact_id'] = checkoutPickupContactId;
    }
    return await httpclient.patch(
      '/items/Attendance_Child/$attendanceId',
      data: data,
    );
  }
}
