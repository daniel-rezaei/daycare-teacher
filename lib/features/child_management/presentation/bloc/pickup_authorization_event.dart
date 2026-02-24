part of 'pickup_authorization_bloc.dart';

sealed class PickupAuthorizationEvent extends Equatable {
  const PickupAuthorizationEvent();

  @override
  List<Object> get props => [];
}

class GetPickupAuthorizationByChildIdEvent extends PickupAuthorizationEvent {
  final String childId;

  const GetPickupAuthorizationByChildIdEvent({required this.childId});

  @override
  List<Object> get props => [childId];
}
