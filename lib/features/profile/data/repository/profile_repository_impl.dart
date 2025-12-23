import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/profile/data/data_source/profile_api.dart';
import 'package:teacher_app/features/profile/data/models/contact_model/contact_model.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/profile/domain/repository/profile_repository.dart';

@Singleton(as: ProfileRepository, env: [Env.prod])
class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileApi profileApi;

  ProfileRepositoryImpl(this.profileApi);

  @override
  Future<DataState<ContactEntity>> getContact({required String id}) async {
    try {
      final Response response = await profileApi.getContact(id: id);

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;

      final ContactEntity contactEntity = ContactModel.fromJson(data);

      return DataSuccess(contactEntity);
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

