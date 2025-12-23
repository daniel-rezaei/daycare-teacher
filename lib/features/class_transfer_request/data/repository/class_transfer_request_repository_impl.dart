import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/class_transfer_request/data/data_source/class_transfer_request_api.dart';
import 'package:teacher_app/features/class_transfer_request/data/models/class_transfer_request_model/class_transfer_request_model.dart';
import 'package:teacher_app/features/class_transfer_request/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/class_transfer_request/domain/repository/class_transfer_request_repository.dart';

@Singleton(as: ClassTransferRequestRepository, env: [Env.prod])
class ClassTransferRequestRepositoryImpl extends ClassTransferRequestRepository {
  final ClassTransferRequestApi api;

  ClassTransferRequestRepositoryImpl(this.api);

  DataState<T> _handleDioError<T>(DioException e) {
    debugPrint('[TRANSFER_REPO] ========== _handleDioError ==========');
    debugPrint('[TRANSFER_REPO] 🐛 DioException Type: ${e.type}');
    debugPrint('[TRANSFER_REPO] 🐛 DioException Message: ${e.message}');
    
    if (e.response != null) {
      debugPrint('[TRANSFER_REPO] 📊 Response Status Code: ${e.response?.statusCode}');
      debugPrint('[TRANSFER_REPO] 📦 Response Data: ${e.response?.data}');
      
      final errorMessage = e.response?.data['errors']?[0]?['message'] as String? ??
          e.response?.data['message'] as String? ??
          'خطا در ارتباط با سرور';
      
      debugPrint('[TRANSFER_REPO] ❌ Error Message: $errorMessage');
      debugPrint('[TRANSFER_REPO] ========== _handleDioError END ==========');
      return DataFailed<T>(errorMessage);
    } else {
      debugPrint('[TRANSFER_REPO] ❌ No response data, using default error message');
      debugPrint('[TRANSFER_REPO] ========== _handleDioError END ==========');
      return DataFailed<T>('خطا در ارتباط با سرور');
    }
  }

  @override
  Future<DataState<ClassTransferRequestEntity>> createTransferRequest({
    required String childId,
    required String fromClassId,
    required String toClassId,
    required String requestedByStaffId,
  }) async {
    try {
      final response = await api.createTransferRequest(
        childId: childId,
        fromClassId: fromClassId,
        toClassId: toClassId,
        requestedByStaffId: requestedByStaffId,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final entity = ClassTransferRequestModel.fromJson(data);

      return DataSuccess(entity);
    } on DioException catch (e) {
      return _handleDioError<ClassTransferRequestEntity>(e);
    }
  }

  @override
  Future<DataState<ClassTransferRequestEntity>> updateTransferRequestStatus({
    required String requestId,
    required String status,
  }) async {
    try {
      final response = await api.updateTransferRequestStatus(
        requestId: requestId,
        status: status,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final entity = ClassTransferRequestModel.fromJson(data);

      return DataSuccess(entity);
    } on DioException catch (e) {
      return _handleDioError<ClassTransferRequestEntity>(e);
    }
  }

  @override
  Future<DataState<ClassTransferRequestEntity?>> getTransferRequestByStudentId({
    required String studentId,
  }) async {
    try {
      final response = await api.getTransferRequestByStudentId(
        studentId: studentId,
      );

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      if (list.isEmpty) {
        return DataSuccess<ClassTransferRequestEntity?>(null);
      }

      final entity = ClassTransferRequestModel.fromJson(
        list.first as Map<String, dynamic>,
      );

      return DataSuccess(entity);
    } on DioException catch (e) {
      return _handleDioError<ClassTransferRequestEntity?>(e);
    }
  }

  @override
  Future<DataState<List<ClassTransferRequestEntity>>> getTransferRequestsByClassId({
    required String classId,
  }) async {
    debugPrint('[TRANSFER_REPO] ========== getTransferRequestsByClassId START ==========');
    debugPrint('[TRANSFER_REPO] 📥 Input classId: $classId');
    
    try {
      debugPrint('[TRANSFER_REPO] 📡 Calling API getTransferRequestsByClassId...');
      final response = await api.getTransferRequestsByClassId(
        classId: classId,
      );

      debugPrint('[TRANSFER_REPO] ✅ API call successful');
      debugPrint('[TRANSFER_REPO] 📦 Response Type: ${response.data.runtimeType}');
      
      if (response.data == null) {
        debugPrint('[TRANSFER_REPO] ⚠️ Response data is null');
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      
      if (response.data is! Map) {
        debugPrint('[TRANSFER_REPO] ⚠️ Response data is not a Map, it is: ${response.data.runtimeType}');
        debugPrint('[TRANSFER_REPO] 📋 Response data: ${response.data}');
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      
      final responseMap = response.data as Map<String, dynamic>;
      debugPrint('[TRANSFER_REPO] 📋 Response Map Keys: ${responseMap.keys.toList()}');
      
      if (!responseMap.containsKey('data')) {
        debugPrint('[TRANSFER_REPO] ⚠️ Response does not contain "data" key');
        debugPrint('[TRANSFER_REPO] 📋 Full response: $responseMap');
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      
      final dataValue = responseMap['data'];
      debugPrint('[TRANSFER_REPO] 📊 Data Value Type: ${dataValue.runtimeType}');
      
      if (dataValue == null) {
        debugPrint('[TRANSFER_REPO] ⚠️ Data value is null');
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      
      if (dataValue is! List) {
        debugPrint('[TRANSFER_REPO] ⚠️ Data is not a List, it is: ${dataValue.runtimeType}');
        debugPrint('[TRANSFER_REPO] 📋 Data content: $dataValue');
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      
      final list = dataValue;
      debugPrint('[TRANSFER_REPO] 📊 List Length: ${list.length}');

      if (list.isEmpty) {
        debugPrint('[TRANSFER_REPO] ✅ List is empty, returning empty list');
        debugPrint('[TRANSFER_REPO] ========== getTransferRequestsByClassId SUCCESS (empty) ==========');
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }

      debugPrint('[TRANSFER_REPO] 🔄 Parsing ${list.length} items...');
      final entities = <ClassTransferRequestEntity>[];
      
      for (int i = 0; i < list.length; i++) {
        try {
          final item = list[i];
          debugPrint('[TRANSFER_REPO] 📋 Item $i Type: ${item.runtimeType}');
          
          if (item is! Map) {
            debugPrint('[TRANSFER_REPO] ⚠️ Item $i is not a Map, skipping');
            continue;
          }
          
          final itemMap = item as Map<String, dynamic>;
          debugPrint('[TRANSFER_REPO] 📋 Item $i Keys: ${itemMap.keys.toList()}');
          debugPrint('[TRANSFER_REPO] 📋 Item $i Content: $itemMap');
          
          final entity = ClassTransferRequestModel.fromJson(itemMap);
          debugPrint('[TRANSFER_REPO] ✅ Item $i parsed successfully: id=${entity.id}, studentId=${entity.studentId}, fromClassId=${entity.fromClassId}, toClassId=${entity.toClassId}, status=${entity.status}');
          entities.add(entity);
        } catch (e, stackTrace) {
          debugPrint('[TRANSFER_REPO] ❌ Error parsing item $i: $e');
          debugPrint('[TRANSFER_REPO] 📍 Stack Trace: $stackTrace');
        }
      }

      debugPrint('[TRANSFER_REPO] ✅ Successfully parsed ${entities.length} entities');
      debugPrint('[TRANSFER_REPO] ========== getTransferRequestsByClassId SUCCESS ==========');
      return DataSuccess(entities);
    } on DioException catch (e) {
      debugPrint('[TRANSFER_REPO] ❌ DioException caught');
      return _handleDioError<List<ClassTransferRequestEntity>>(e);
    } catch (e, stackTrace) {
      debugPrint('[TRANSFER_REPO] ❌ Unexpected Exception');
      debugPrint('[TRANSFER_REPO] 🐛 Exception Type: ${e.runtimeType}');
      debugPrint('[TRANSFER_REPO] 🐛 Exception Message: $e');
      debugPrint('[TRANSFER_REPO] 📍 Stack Trace:');
      debugPrint('[TRANSFER_REPO] $stackTrace');
      debugPrint('[TRANSFER_REPO] ========== getTransferRequestsByClassId ERROR ==========');
      return DataFailed<List<ClassTransferRequestEntity>>('خطا غیرمنتظره: $e');
    }
  }
}

