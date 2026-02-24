part of 'child_bloc.dart';

sealed class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object> get props => [];
}

class GetAllChildrenEvent extends ChildEvent {
  const GetAllChildrenEvent();
}

class GetAllContactsEvent extends ChildEvent {
  const GetAllContactsEvent();
}

class GetAllDietaryRestrictionsEvent extends ChildEvent {
  const GetAllDietaryRestrictionsEvent();
}

class GetAllMedicationsEvent extends ChildEvent {
  const GetAllMedicationsEvent();
}

class GetAllPhysicalRequirementsEvent extends ChildEvent {
  const GetAllPhysicalRequirementsEvent();
}

class GetAllReportableDiseasesEvent extends ChildEvent {
  const GetAllReportableDiseasesEvent();
}

class GetAllImmunizationsEvent extends ChildEvent {
  const GetAllImmunizationsEvent();
}

class GetChildByIdEvent extends ChildEvent {
  final String childId;
  const GetChildByIdEvent({required this.childId});
  @override
  List<Object> get props => [childId];
}

class GetChildByContactIdEvent extends ChildEvent {
  final String contactId;
  const GetChildByContactIdEvent({required this.contactId});
  @override
  List<Object> get props => [contactId];
}
