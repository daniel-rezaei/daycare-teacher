import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ClassTransferRequestApi {
  final Dio httpclient;
  ClassTransferRequestApi(this.httpclient);

  /// Create a new class transfer request
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

  /// Update transfer request status
  Future<Response> updateTransferRequestStatus({
    required String requestId,
    required String status,
  }) async {
    return await httpclient.patch(
      '/items/Class_Transfer_Request/$requestId',
      data: {
        'status': status,
      },
    );
  }

  /// Get transfer request by student ID
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

  /// Get transfer requests by class ID (for both source and destination class teachers)
  /// Returns requests where from_class_id OR to_class_id matches the classId
  Future<Response> getTransferRequestsByClassId({
    required String classId,
  }) async {
    debugPrint('[TRANSFER_API] ========== getTransferRequestsByClassId START ==========');
    debugPrint('[TRANSFER_API] 📥 Input classId: $classId');
    
    final queryParams = {
        'filter[_or][0][from_class_id][_eq]': classId,
        'filter[_or][1][to_class_id][_eq]': classId,
        'filter[status][_eq]': 'pending',
        'fields': 'id,student_id,from_class_id,to_class_id,status',
        'sort': '-id',
    };
    
    debugPrint('[TRANSFER_API] 📤 Query Parameters:');
    queryParams.forEach((key, value) {
      debugPrint('[TRANSFER_API]   $key: $value');
    });
    debugPrint('[TRANSFER_API] 📡 URL: /items/Class_Transfer_Request');
    
    try {
      final response = await httpclient.get(
        '/items/Class_Transfer_Request',
        queryParameters: queryParams,
      );
      
      debugPrint('[TRANSFER_API] ✅ Response received');
      debugPrint('[TRANSFER_API] 📊 Status Code: ${response.statusCode}');
      debugPrint('[TRANSFER_API] 📦 Response Data Type: ${response.data.runtimeType}');
      
      if (response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[TRANSFER_API] 📋 Response Keys: ${data.keys.toList()}');
        
        if (data.containsKey('data')) {
          final dataList = data['data'];
          debugPrint('[TRANSFER_API] 📊 Data Type: ${dataList.runtimeType}');
          
          if (dataList is List) {
            debugPrint('[TRANSFER_API] 📊 Data List Length: ${dataList.length}');
            if (dataList.isNotEmpty) {
              debugPrint('[TRANSFER_API] 📋 First Item: ${dataList.first}');
            } else {
              debugPrint('[TRANSFER_API] ⚠️ Data list is empty');
            }
          } else {
            debugPrint('[TRANSFER_API] ⚠️ Data is not a List, it is: ${dataList.runtimeType}');
            debugPrint('[TRANSFER_API] 📋 Data content: $dataList');
          }
        } else {
          debugPrint('[TRANSFER_API] ⚠️ Response does not contain "data" key');
          debugPrint('[TRANSFER_API] 📋 Full response: $data');
        }
      } else {
        debugPrint('[TRANSFER_API] ⚠️ Response data is null or not a Map');
        debugPrint('[TRANSFER_API] 📋 Response data: ${response.data}');
      }
      
      debugPrint('[TRANSFER_API] ========== getTransferRequestsByClassId SUCCESS ==========');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[TRANSFER_API] ❌ ERROR in getTransferRequestsByClassId');
      debugPrint('[TRANSFER_API] 🐛 Exception Type: ${e.runtimeType}');
      debugPrint('[TRANSFER_API] 🐛 Exception Message: $e');
      debugPrint('[TRANSFER_API] 📍 Stack Trace:');
      debugPrint('[TRANSFER_API] $stackTrace');
      
      if (e is DioException) {
        debugPrint('[TRANSFER_API] 🔴 DioException Details:');
        debugPrint('[TRANSFER_API]   Type: ${e.type}');
        debugPrint('[TRANSFER_API]   Message: ${e.message}');
        debugPrint('[TRANSFER_API]   Response Status Code: ${e.response?.statusCode}');
        debugPrint('[TRANSFER_API]   Response Data: ${e.response?.data}');
        debugPrint('[TRANSFER_API]   Request Options: ${e.requestOptions.uri}');
        debugPrint('[TRANSFER_API]   Request Headers: ${e.requestOptions.headers}');
      }
      
      debugPrint('[TRANSFER_API] ========== getTransferRequestsByClassId ERROR ==========');
      rethrow;
    }
  }
}

