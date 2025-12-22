part of 'child_bloc.dart';

sealed class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching all children
class GetAllChildrenEvent extends ChildEvent {
  const GetAllChildrenEvent();
}

/// Event for fetching all contacts
class GetAllContactsEvent extends ChildEvent {
  const GetAllContactsEvent();
}

/// Event for fetching all dietary restrictions
class GetAllDietaryRestrictionsEvent extends ChildEvent {
  const GetAllDietaryRestrictionsEvent();
}

/// Event for fetching all medications
class GetAllMedicationsEvent extends ChildEvent {
  const GetAllMedicationsEvent();
}

/// Event for fetching all physical requirements
class GetAllPhysicalRequirementsEvent extends ChildEvent {
  const GetAllPhysicalRequirementsEvent();
}

/// Event for fetching all reportable diseases
class GetAllReportableDiseasesEvent extends ChildEvent {
  const GetAllReportableDiseasesEvent();
}

/// Event for fetching all immunizations
class GetAllImmunizationsEvent extends ChildEvent {
  const GetAllImmunizationsEvent();
}

/// Event for fetching a child by ID
class GetChildByIdEvent extends ChildEvent {
  final String childId;
  const GetChildByIdEvent({required this.childId});
  @override
  List<Object> get props => [childId];
}

/// Event for fetching a child by contact_id
class GetChildByContactIdEvent extends ChildEvent {
  final String contactId;
  const GetChildByContactIdEvent({required this.contactId});
  @override
  List<Object> get props => [contactId];
}

