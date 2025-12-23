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
    on<CreatePickupAuthorizationEvent>(_createPickupAuthorizationEvent);
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

  FutureOr<void> _createPickupAuthorizationEvent(
    CreatePickupAuthorizationEvent event,
    Emitter<PickupAuthorizationState> emit,
  ) async {
    debugPrint('[CHECKOUT_DEBUG] _createPickupAuthorizationEvent called');
    debugPrint('[CHECKOUT_DEBUG] - childId: ${event.childId}');
    debugPrint('[CHECKOUT_DEBUG] - authorizedContactId: ${event.authorizedContactId}');
    debugPrint('[CHECKOUT_DEBUG] - note: ${event.note}');
    
    emit(const CreatePickupAuthorizationLoading());

    try {
      debugPrint('[CHECKOUT_DEBUG] Calling pickupAuthorizationUsecase.createPickupAuthorization');
      DataState dataState = await pickupAuthorizationUsecase.createPickupAuthorization(
        childId: event.childId,
        authorizedContactId: event.authorizedContactId,
        note: event.note,
      );

      debugPrint('[CHECKOUT_DEBUG] DataState received: ${dataState.runtimeType}');
      
      if (dataState is DataSuccess) {
        debugPrint('[CHECKOUT_DEBUG] CreatePickupAuthorizationSuccess');
        emit(CreatePickupAuthorizationSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint('[CHECKOUT_DEBUG] CreatePickupAuthorizationFailure: ${dataState.error}');
        emit(CreatePickupAuthorizationFailure(dataState.error!));
      }
    } catch (e, stackTrace) {
      debugPrint('[CHECKOUT_DEBUG] Exception creating pickup authorization: $e');
      debugPrint('[CHECKOUT_DEBUG] StackTrace: $stackTrace');
      emit(const CreatePickupAuthorizationFailure('Error creating authorization'));
    }
  }
}

