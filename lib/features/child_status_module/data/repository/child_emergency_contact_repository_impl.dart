import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child_status_module/data/data_source/child_emergency_contact_api.dart';
import 'package:teacher_app/features/child_status_module/data/models/child_emergency_contact_model.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_emergency_contact_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/repository/child_emergency_contact_repository.dart';

@Singleton(as: ChildEmergencyContactRepository, env: [Env.prod])
class ChildEmergencyContactRepositoryImpl
    extends ChildEmergencyContactRepository {
  final ChildEmergencyContactApi childEmergencyContactApi;

  ChildEmergencyContactRepositoryImpl(this.childEmergencyContactApi);

  @override
  Future<DataState<List<ChildEmergencyContactEntity>>>
      getAllChildEmergencyContacts() async {
    try {
      final Response response =
          await childEmergencyContactApi.getAllChildEmergencyContacts();
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<ChildEmergencyContactEntity> emergencyContactList = dataList
          .map((data) => ChildEmergencyContactModel.fromJson(
              data as Map<String, dynamic>))
          .toList();
      return DataSuccess(emergencyContactList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'Error retrieving information';
    if (e.response != null) {
      errorMessage = e.response?.data['message'] ??
          e.response?.statusMessage ??
          'Error connecting to server';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Error connecting to server';
    }
    return DataFailed(errorMessage);
  }
}
