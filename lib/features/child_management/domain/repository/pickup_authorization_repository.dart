import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/pickup_authorization_entity.dart';

abstract class PickupAuthorizationRepository {
  Future<DataState<List<PickupAuthorizationEntity>>> getPickupAuthorizationByChildId({
    required String childId,
  });
}
