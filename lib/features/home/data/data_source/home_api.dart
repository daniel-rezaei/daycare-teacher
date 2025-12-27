import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class HomeApi {
  final Dio httpclient;
  HomeApi(this.httpclient);

  // ========== Auth APIs ==========
  Future<dynamic> classRoom() async {
    final response = await httpclient.get('/items/Class');
    return response;
  }

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

  // ========== Profile APIs ==========
  Future<Response> getContact({required String id}) async {
    return await httpclient.get('/items/Contacts/$id');
  }

  Future<Response> getAllContacts() async {
    return await httpclient.get('/items/Contacts');
  }

  // ========== Session APIs ==========
  Future<Response> getSessionByClassId({required String classId}) async {
    return await httpclient.get(
      '/items/Staff_Class_Session',
      queryParameters: {
        'filter[class_id][_eq]': classId,
        'fields': 'id,start_at,end_at,staff_id,class_id',
        'sort': '-start_at',
        'limit': 1,
      },
    );
  }

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

  // ========== Child APIs ==========
  Future<Response> getAllChildren() async {
    return await httpclient.get('/items/Child');
  }

  Future<Response> getAllDietaryRestrictions() async {
    return await httpclient.get('/items/child_dietary_restrictions');
  }

  Future<Response> getAllMedications() async {
    return await httpclient.get('/items/Medication');
  }

  Future<Response> getAllPhysicalRequirements() async {
    return await httpclient.get('/items/child_physical_requirements');
  }

  Future<Response> getAllReportableDiseases() async {
    return await httpclient.get('/items/child_reportable_diseases');
  }

  Future<Response> getChildById({required String childId}) async {
    return await httpclient.get(
      '/items/Child/$childId',
      queryParameters: {
        'fields': 'id,dob,language,photo,contact_id,status,date_created,date_updated',
      },
    );
  }

  Future<Response> getChildByContactId({required String contactId}) async {
    return await httpclient.get(
      '/items/Child',
      queryParameters: {
        'filter[contact_id][_eq]': contactId,
        'fields': 'id,dob,language,photo,contact_id,status,date_created,date_updated',
        'limit': 1,
      },
    );
  }

  // ========== Attendance APIs ==========
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
        'fields': 'id,check_in_at,check_out_at,child_id,class_id,staff_id,check_in_method,check_out_method,Notes',
      },
    );
  }

  Future<Response> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo, // String of file ID (first file ID if multiple)
    String? pickupAuthorizationId, // DOMAIN LOCKDOWN: Only accepts existing PickupAuthorization ID
  }) async {
    // DOMAIN LOCKDOWN: Checkout API accepts ONLY pickup_authorization_id
    // No contact/guardian/pickup creation allowed from checkout flow
    final data = <String, dynamic>{
      'check_out_at': checkOutAt,
      'check_out_method': 'manually',
    };

    // اضافه کردن فیلدهای اختیاری فقط در صورت وجود
    if (notes != null && notes.isNotEmpty) {
      data['Notes'] = notes; // استفاده از 'Notes' با N بزرگ
    }

    if (photo != null && photo.isNotEmpty) {
      data['photo'] = photo;
    }

    // DOMAIN LOCKDOWN: Only accept pickup_authorization_id (existing authorization)
    // Reject any contact/guardian/pickup creation attempts
    if (pickupAuthorizationId != null && pickupAuthorizationId.isNotEmpty) {
      data['pickup_authorization_id'] = pickupAuthorizationId;
    }

    // PATCH مستقیم بدون wrapper - مشابه createAttendance
    return await httpclient.patch(
      '/items/Attendance_Child/$attendanceId',
      data: data,
    );
  }

  // ========== Notification APIs ==========
  Future<Response> getAllNotifications() async {
    return await httpclient.get('/items/notifications');
  }

  // ========== Event APIs ==========
  Future<Response> getAllEvents() async {
    return await httpclient.get('/items/Events');
  }
}

