import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';

abstract class PickupAuthorizationRepository {
  Future<DataState<List<PickupAuthorizationEntity>>> getPickupAuthorizationByChildId({
    required String childId,
  });

  Future<DataState<PickupAuthorizationEntity>> createPickupAuthorization({
    required String childId,
    required String authorizedContactId,
    String? note,
  });
}

