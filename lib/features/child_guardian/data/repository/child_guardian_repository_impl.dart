import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child_guardian/data/data_source/child_guardian_api.dart';
import 'package:teacher_app/features/child_guardian/data/models/child_guardian_model/child_guardian_model.dart';
import 'package:teacher_app/features/child_guardian/domain/entity/child_guardian_entity.dart';
import 'package:teacher_app/features/child_guardian/domain/repository/child_guardian_repository.dart';

@Singleton(as: ChildGuardianRepository, env: [Env.prod])
class ChildGuardianRepositoryImpl extends ChildGuardianRepository {
  final ChildGuardianApi childGuardianApi;

  ChildGuardianRepositoryImpl(this.childGuardianApi);

  @override
  Future<DataState<List<ChildGuardianEntity>>> getChildGuardianByChildId({
    required String childId,
  }) async {
    try {
      final Response response = await childGuardianApi.getChildGuardianByChildId(
        childId: childId,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<ChildGuardianEntity> guardianList = dataList
          .map((data) => ChildGuardianModel.fromJson(data as Map<String, dynamic>))
          .toList();

      return DataSuccess(guardianList);
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

