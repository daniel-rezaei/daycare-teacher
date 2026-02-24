import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ClassTransferRequestApi {
  final Dio httpclient;
  ClassTransferRequestApi(this.httpclient);

  Future<Response> createTransferRequest({
    required String childId,
    required String fromClassId,
    required String toClassId,
    required String requestedByStaffId,
  }) async {
    return await httpclient.post(
      '/items/Class_Transfer_Request',
      data: {
        'child_id': childId,
        'from_class_id': fromClassId,
        'to_class_id': toClassId,
        'requested_by_staff_id': requestedByStaffId,
        'status': 'pending',
      },
    );
  }

  Future<Response> updateTransferRequestStatus({
    required String requestId,
    required String status,
  }) async {
    return await httpclient.patch(
      '/items/Class_Transfer_Request/$requestId',
      data: {'status': status},
    );
  }

  Future<Response> getTransferRequestByStudentId({
    required String studentId,
  }) async {
    return await httpclient.get(
      '/items/Class_Transfer_Request',
      queryParameters: {
        'filter[student_id][_eq]': studentId,
        'filter[status][_eq]': 'pending',
        'fields': 'id,student_id,from_class_id,to_class_id,status',
        'limit': 1,
        'sort': '-id',
      },
    );
  }

  Future<Response> getTransferRequestsByClassId({
    required String classId,
  }) async {
    final queryParams = {
      'filter[_or][0][from_class_id][_eq]': classId,
      'filter[_or][1][to_class_id][_eq]': classId,
      'filter[status][_eq]': 'pending',
      'fields': 'id,student_id,from_class_id,to_class_id,status',
      'sort': '-id',
    };
    return await httpclient.get(
      '/items/Class_Transfer_Request',
      queryParameters: queryParams,
    );
  }
}
