import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';
import 'package:teacher_app/features/pickup_authorization/domain/repository/pickup_authorization_repository.dart';

@singleton
class PickupAuthorizationUsecase {
  final PickupAuthorizationRepository pickupAuthorizationRepository;

  PickupAuthorizationUsecase(this.pickupAuthorizationRepository);

  Future<DataState<List<PickupAuthorizationEntity>>> getPickupAuthorizationByChildId({
    required String childId,
  }) async {
    return await pickupAuthorizationRepository.getPickupAuthorizationByChildId(
      childId: childId,
    );
  }

  // NOTE: PickupAuthorization creation removed - only Guardian/Admin flows can create pickups.
  // Teachers can ONLY SELECT existing authorized pickups.
}

