part of 'child_emergency_contact_bloc.dart';

sealed class ChildEmergencyContactEvent extends Equatable {
  const ChildEmergencyContactEvent();

  @override
  List<Object> get props => [];
}

class GetAllChildEmergencyContactsEvent
    extends ChildEmergencyContactEvent {
  const GetAllChildEmergencyContactsEvent();
}

