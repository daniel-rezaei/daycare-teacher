part of 'child_emergency_contact_bloc.dart';

sealed class ChildEmergencyContactState extends Equatable {
  const ChildEmergencyContactState();

  @override
  List<Object?> get props => [];
}

final class ChildEmergencyContactInitial extends ChildEmergencyContactState {
  const ChildEmergencyContactInitial();
}

final class GetAllChildEmergencyContactsLoading
    extends ChildEmergencyContactState {
  const GetAllChildEmergencyContactsLoading();
}

final class GetAllChildEmergencyContactsSuccess
    extends ChildEmergencyContactState {
  final List<ChildEmergencyContactEntity> emergencyContactList;
  const GetAllChildEmergencyContactsSuccess(this.emergencyContactList);
  @override
  List<Object?> get props => [emergencyContactList];
}

final class GetAllChildEmergencyContactsFailure
    extends ChildEmergencyContactState {
  final String message;
  const GetAllChildEmergencyContactsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

