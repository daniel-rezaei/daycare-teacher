import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/notification/data/data_source/notification_api.dart';
import 'package:teacher_app/features/notification/data/models/notification_model/notification_model.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/notification/domain/repository/notification_repository.dart';

@Singleton(as: NotificationRepository, env: [Env.prod])
class NotificationRepositoryImpl extends NotificationRepository {
  final NotificationApi notificationApi;

  NotificationRepositoryImpl(this.notificationApi);

  @override
  Future<DataState<List<NotificationEntity>>> getAllNotifications() async {
    try {
      final Response response = await notificationApi.getAllNotifications();

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;

      final List<NotificationEntity> notificationList = dataList
          .map((data) => NotificationModel.fromJson(
              data as Map<String, dynamic>))
          .toList();

      return DataSuccess(notificationList);
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

