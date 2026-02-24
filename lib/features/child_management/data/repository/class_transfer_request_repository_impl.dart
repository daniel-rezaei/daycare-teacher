import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child_management/data/data_source/class_transfer_request_api.dart';
import 'package:teacher_app/features/child_management/data/models/class_transfer_request_model.dart';
import 'package:teacher_app/features/child_management/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/class_transfer_request_repository.dart';

@Singleton(as: ClassTransferRequestRepository, env: [Env.prod])
class ClassTransferRequestRepositoryImpl
    extends ClassTransferRequestRepository {
  final ClassTransferRequestApi api;

  ClassTransferRequestRepositoryImpl(this.api);

  DataState<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final errorMessage =
          e.response?.data['errors']?[0]?['message'] as String? ??
              e.response?.data['message'] as String? ??
              'Error connecting to server';
      return DataFailed<T>(errorMessage);
    } else {
      return DataFailed<T>('Error connecting to server');
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
      return DataSuccess(ClassTransferRequestModel.fromJson(data));
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
      return DataSuccess(ClassTransferRequestModel.fromJson(data));
    } on DioException catch (e) {
      return _handleDioError<ClassTransferRequestEntity>(e);
    }
  }

  @override
  Future<DataState<ClassTransferRequestEntity?>> getTransferRequestByStudentId({
    required String studentId,
  }) async {
    try {
      final response =
          await api.getTransferRequestByStudentId(studentId: studentId);
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      if (list.isEmpty) {
        return DataSuccess<ClassTransferRequestEntity?>(null);
      }
      return DataSuccess(ClassTransferRequestModel.fromJson(
          list.first as Map<String, dynamic>));
    } on DioException catch (e) {
      return _handleDioError<ClassTransferRequestEntity?>(e);
    }
  }

  @override
  Future<DataState<List<ClassTransferRequestEntity>>>
      getTransferRequestsByClassId({required String classId}) async {
    try {
      final response = await api.getTransferRequestsByClassId(classId: classId);
      if (response.data == null) {
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      if (response.data is! Map) {
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      final responseMap = response.data as Map<String, dynamic>;
      if (!responseMap.containsKey('data')) {
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      final dataValue = responseMap['data'];
      if (dataValue == null || dataValue is! List) {
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      final list = dataValue;
      if (list.isEmpty) {
        return DataSuccess<List<ClassTransferRequestEntity>>([]);
      }
      final entities = <ClassTransferRequestEntity>[];
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item is! Map) continue;
        entities.add(
            ClassTransferRequestModel.fromJson(item as Map<String, dynamic>));
      }
      return DataSuccess(entities);
    } on DioException catch (e) {
      return _handleDioError<List<ClassTransferRequestEntity>>(e);
    } catch (e) {
      return DataFailed<List<ClassTransferRequestEntity>>(
          'Unexpected error: $e');
    }
  }
}
