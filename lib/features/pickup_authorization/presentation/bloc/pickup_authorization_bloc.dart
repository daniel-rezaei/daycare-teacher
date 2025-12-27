import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';
import 'package:teacher_app/features/pickup_authorization/domain/usecase/pickup_authorization_usecase.dart';

part 'pickup_authorization_event.dart';
part 'pickup_authorization_state.dart';

@injectable
class PickupAuthorizationBloc
    extends Bloc<PickupAuthorizationEvent, PickupAuthorizationState> {
  final PickupAuthorizationUsecase pickupAuthorizationUsecase;
  PickupAuthorizationBloc(this.pickupAuthorizationUsecase)
      : super(const PickupAuthorizationInitial()) {
    on<GetPickupAuthorizationByChildIdEvent>(_getPickupAuthorizationByChildIdEvent);
    // NOTE: CreatePickupAuthorizationEvent removed - only Guardian/Admin flows can create pickups.
    // Teachers can ONLY SELECT existing authorized pickups.
  }

  FutureOr<void> _getPickupAuthorizationByChildIdEvent(
    GetPickupAuthorizationByChildIdEvent event,
    Emitter<PickupAuthorizationState> emit,
  ) async {
    emit(const GetPickupAuthorizationByChildIdLoading());

    try {
      DataState dataState = await pickupAuthorizationUsecase.getPickupAuthorizationByChildId(
        childId: event.childId,
      );

      if (dataState is DataSuccess) {
        debugPrint(
            '[PICKUP_AUTH_DEBUG] GetPickupAuthorizationByChildIdSuccess: ${dataState.data?.length} items');
        emit(GetPickupAuthorizationByChildIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[PICKUP_AUTH_DEBUG] GetPickupAuthorizationByChildIdFailure: ${dataState.error}');
        emit(GetPickupAuthorizationByChildIdFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[PICKUP_AUTH_DEBUG] Exception getting pickup authorization: $e');
      emit(const GetPickupAuthorizationByChildIdFailure('Error retrieving information'));
    }
  }

  // NOTE: _createPickupAuthorizationEvent removed - only Guardian/Admin flows can create pickups.
  // Teachers can ONLY SELECT existing authorized pickups.
}

