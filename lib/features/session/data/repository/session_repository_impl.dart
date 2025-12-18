import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/session/data/data_source/session_api.dart';
import 'package:teacher_app/features/session/data/models/staff_class_session_model/staff_class_session_model.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/features/session/domain/repository/session_repository.dart';

@Singleton(as: SessionRepository, env: [Env.prod])
class SessionRepositoryImpl extends SessionRepository {
  final SessionApi sessionApi;

  SessionRepositoryImpl(this.sessionApi);

  @override
  Future<DataState<StaffClassSessionEntity?>> getSessionByClassId({
    required String classId,
  }) async {
    try {
      final Response response = await sessionApi.getSessionByClassId(
        classId: classId,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;

      if (dataList.isEmpty) {
        // اگر session وجود نداشت، null برمی‌گردانیم
        return DataSuccess(null);
      }

      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      final StaffClassSessionEntity sessionEntity =
          StaffClassSessionModel.fromJson(data);

      return DataSuccess(sessionEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<StaffClassSessionEntity>> createSession({
    required String staffId,
    required String classId,
    required String startAt,
  }) async {
    try {
      final Response response = await sessionApi.createSession(
        staffId: staffId,
        classId: classId,
        startAt: startAt,
      );

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final StaffClassSessionEntity sessionEntity =
          StaffClassSessionModel.fromJson(data);

      return DataSuccess(sessionEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<StaffClassSessionEntity>> updateSession({
    required String sessionId,
    required String endAt,
  }) async {
    try {
      final Response response = await sessionApi.updateSession(
        sessionId: sessionId,
        endAt: endAt,
      );

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final StaffClassSessionEntity sessionEntity =
          StaffClassSessionModel.fromJson(data);

      return DataSuccess(sessionEntity);
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


