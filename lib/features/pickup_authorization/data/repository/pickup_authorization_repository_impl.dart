import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/pickup_authorization/data/data_source/pickup_authorization_api.dart';
import 'package:teacher_app/features/pickup_authorization/data/models/pickup_authorization_model/pickup_authorization_model.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';
import 'package:teacher_app/features/pickup_authorization/domain/repository/pickup_authorization_repository.dart';

@Singleton(as: PickupAuthorizationRepository, env: [Env.prod])
class PickupAuthorizationRepositoryImpl extends PickupAuthorizationRepository {
  final PickupAuthorizationApi pickupAuthorizationApi;

  PickupAuthorizationRepositoryImpl(this.pickupAuthorizationApi);

  @override
  Future<DataState<List<PickupAuthorizationEntity>>> getPickupAuthorizationByChildId({
    required String childId,
  }) async {
    try {
      final Response response = await pickupAuthorizationApi.getPickupAuthorizationByChildId(
        childId: childId,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<PickupAuthorizationEntity> pickupAuthorizationList = dataList
          .map((data) => PickupAuthorizationModel.fromJson(data as Map<String, dynamic>))
          .toList();

      return DataSuccess(pickupAuthorizationList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<PickupAuthorizationEntity>> createPickupAuthorization({
    required String childId,
    required String authorizedContactId,
    String? note,
  }) async {
    try {
      debugPrint('[CHECKOUT_DEBUG] Repository: createPickupAuthorization called');
      debugPrint('[CHECKOUT_DEBUG] Repository: childId=$childId, authorizedContactId=$authorizedContactId, note=$note');
      
      final Response response = await pickupAuthorizationApi.createPickupAuthorization(
        childId: childId,
        authorizedContactId: authorizedContactId,
        note: note,
      );

      debugPrint('[CHECKOUT_DEBUG] Repository: Response statusCode=${response.statusCode}');
      debugPrint('[CHECKOUT_DEBUG] Repository: Response data=${response.data}');

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final PickupAuthorizationEntity pickupAuthorization = 
          PickupAuthorizationModel.fromJson(data);

      debugPrint('[CHECKOUT_DEBUG] Repository: Success, returning DataSuccess');
      return DataSuccess(pickupAuthorization);
    } on DioException catch (e) {
      debugPrint('[CHECKOUT_DEBUG] Repository: DioException: ${e.message}');
      debugPrint('[CHECKOUT_DEBUG] Repository: DioException response: ${e.response?.data}');
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

