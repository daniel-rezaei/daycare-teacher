import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';

abstract class PickupAuthorizationRepository {
  Future<DataState<List<PickupAuthorizationEntity>>> getPickupAuthorizationByChildId({
    required String childId,
  });

  // NOTE: PickupAuthorization creation is ONLY allowed from Guardian/Admin flows.
  // Teachers can ONLY SELECT existing authorized pickups.
  // This method has been removed to enforce domain integrity.
}

