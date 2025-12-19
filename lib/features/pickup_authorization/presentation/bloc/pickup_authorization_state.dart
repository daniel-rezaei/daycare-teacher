part of 'pickup_authorization_bloc.dart';

sealed class PickupAuthorizationState extends Equatable {
  const PickupAuthorizationState();

  @override
  List<Object?> get props => [];
}

final class PickupAuthorizationInitial extends PickupAuthorizationState {
  const PickupAuthorizationInitial();
}

final class GetPickupAuthorizationByChildIdLoading extends PickupAuthorizationState {
  const GetPickupAuthorizationByChildIdLoading();
}

final class GetPickupAuthorizationByChildIdSuccess extends PickupAuthorizationState {
  final List<PickupAuthorizationEntity> pickupAuthorizationList;
  const GetPickupAuthorizationByChildIdSuccess(this.pickupAuthorizationList);
  @override
  List<Object?> get props => [pickupAuthorizationList];
}

final class GetPickupAuthorizationByChildIdFailure extends PickupAuthorizationState {
  final String message;
  const GetPickupAuthorizationByChildIdFailure(this.message);
  @override
  List<Object?> get props => [message];
}

final class CreatePickupAuthorizationLoading extends PickupAuthorizationState {
  const CreatePickupAuthorizationLoading();
}

final class CreatePickupAuthorizationSuccess extends PickupAuthorizationState {
  final PickupAuthorizationEntity pickupAuthorization;
  const CreatePickupAuthorizationSuccess(this.pickupAuthorization);
  @override
  List<Object?> get props => [pickupAuthorization];
}

final class CreatePickupAuthorizationFailure extends PickupAuthorizationState {
  final String message;
  const CreatePickupAuthorizationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

