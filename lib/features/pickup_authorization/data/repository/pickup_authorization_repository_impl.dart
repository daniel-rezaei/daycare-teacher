import 'package:dio/dio.dart';
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
  Future<DataState<List<PickupAuthorizationEntity>>>
  getPickupAuthorizationByChildId({required String childId}) async {
    try {
      final Response response = await pickupAuthorizationApi
          .getPickupAuthorizationByChildId(childId: childId);

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<PickupAuthorizationEntity> pickupAuthorizationList = dataList
          .map(
            (data) =>
                PickupAuthorizationModel.fromJson(data as Map<String, dynamic>),
          )
          .toList();

      return DataSuccess(pickupAuthorizationList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // NOTE: PickupAuthorization creation removed - only Guardian/Admin flows can create pickups.
  // Teachers can ONLY SELECT existing authorized pickups.

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'Error retrieving information';

    if (e.response != null) {
      errorMessage =
          e.response?.data['message'] ??
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
