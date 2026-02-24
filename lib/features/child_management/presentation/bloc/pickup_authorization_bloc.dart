import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/pickup_authorization_entity.dart';
import 'package:teacher_app/features/child_management/domain/usecase/pickup_authorization_usecase.dart';

part 'pickup_authorization_event.dart';
part 'pickup_authorization_state.dart';

@injectable
class PickupAuthorizationBloc
    extends Bloc<PickupAuthorizationEvent, PickupAuthorizationState> {
  final PickupAuthorizationUsecase pickupAuthorizationUsecase;
  PickupAuthorizationBloc(this.pickupAuthorizationUsecase)
    : super(const PickupAuthorizationInitial()) {
    on<GetPickupAuthorizationByChildIdEvent>(
      _getPickupAuthorizationByChildIdEvent,
    );
  }

  FutureOr<void> _getPickupAuthorizationByChildIdEvent(
    GetPickupAuthorizationByChildIdEvent event,
    Emitter<PickupAuthorizationState> emit,
  ) async {
    emit(const GetPickupAuthorizationByChildIdLoading());

    try {
      DataState dataState = await pickupAuthorizationUsecase
          .getPickupAuthorizationByChildId(childId: event.childId);

      if (dataState is DataSuccess) {
        emit(GetPickupAuthorizationByChildIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        emit(GetPickupAuthorizationByChildIdFailure(dataState.error!));
      }
    } catch (e) {
      emit(
        const GetPickupAuthorizationByChildIdFailure(
          'Error retrieving information',
        ),
      );
    }
  }
}
