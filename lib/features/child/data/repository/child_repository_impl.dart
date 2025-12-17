import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child/data/data_source/child_api.dart';
import 'package:teacher_app/features/child/data/models/child_model/child_model.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/domain/repository/child_repository.dart';
import 'package:teacher_app/features/profile/data/data_source/profile_api.dart';
import 'package:teacher_app/features/profile/data/models/contact_model/contact_model.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

@Singleton(as: ChildRepository, env: [Env.prod])
class ChildRepositoryImpl extends ChildRepository {
  final ChildApi childApi;
  final ProfileApi profileApi;

  ChildRepositoryImpl(this.childApi, this.profileApi);

  @override
  Future<DataState<List<ChildEntity>>> getAllChildren() async {
    try {
      final Response response = await childApi.getAllChildren();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<ChildEntity> childrenEntity = list
          .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(childrenEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<ContactEntity>>> getAllContacts() async {
    try {
      final Response response = await profileApi.getAllContacts();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<ContactEntity> contactsEntity = list
          .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(contactsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'خطا در دریافت اطلاعات';
    
    if (e.response != null) {
      errorMessage = e.response?.data['message'] ?? 
                     e.response?.statusMessage ?? 
                     'خطا در ارتباط با سرور';
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'زمان اتصال به سرور به پایان رسید';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'خطا در اتصال به سرور';
    }

    return DataFailed(errorMessage);
  }
}

