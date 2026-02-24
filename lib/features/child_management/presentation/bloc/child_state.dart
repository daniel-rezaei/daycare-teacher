part of 'child_bloc.dart';

sealed class ChildState extends Equatable {
  final List<ChildEntity>? children;
  final List<ContactEntity>? contacts;
  final List<DietaryRestrictionEntity>? dietaryRestrictions;
  final List<MedicationEntity>? medications;
  final List<PhysicalRequirementEntity>? physicalRequirements;
  final List<ReportableDiseaseEntity>? reportableDiseases;
  final List<ImmunizationEntity>? immunizations;
  final ChildEntity? child;
  final bool isLoadingChildren;
  final bool isLoadingContacts;
  final bool isLoadingDietaryRestrictions;
  final bool isLoadingMedications;
  final bool isLoadingPhysicalRequirements;
  final bool isLoadingReportableDiseases;
  final bool isLoadingImmunizations;
  final bool isLoadingChild;
  final String? childrenError;
  final String? contactsError;
  final String? dietaryRestrictionsError;
  final String? medicationsError;
  final String? physicalRequirementsError;
  final String? reportableDiseasesError;
  final String? immunizationsError;
  final String? childError;

  const ChildState({
    this.children,
    this.contacts,
    this.dietaryRestrictions,
    this.medications,
    this.physicalRequirements,
    this.reportableDiseases,
    this.immunizations,
    this.child,
    this.isLoadingChildren = false,
    this.isLoadingContacts = false,
    this.isLoadingDietaryRestrictions = false,
    this.isLoadingMedications = false,
    this.isLoadingPhysicalRequirements = false,
    this.isLoadingReportableDiseases = false,
    this.isLoadingImmunizations = false,
    this.isLoadingChild = false,
    this.childrenError,
    this.contactsError,
    this.dietaryRestrictionsError,
    this.medicationsError,
    this.physicalRequirementsError,
    this.reportableDiseasesError,
    this.immunizationsError,
    this.childError,
  });

  @override
  List<Object?> get props => [
        children,
        contacts,
        dietaryRestrictions,
        medications,
        physicalRequirements,
        reportableDiseases,
        immunizations,
        child,
        isLoadingChildren,
        isLoadingContacts,
        isLoadingDietaryRestrictions,
        isLoadingMedications,
        isLoadingPhysicalRequirements,
        isLoadingReportableDiseases,
        isLoadingImmunizations,
        isLoadingChild,
        childrenError,
        contactsError,
        dietaryRestrictionsError,
        medicationsError,
        physicalRequirementsError,
        reportableDiseasesError,
        immunizationsError,
        childError,
      ];
}

final class ChildInitial extends ChildState {
  const ChildInitial();
}

final class GetAllChildrenLoading extends ChildState {
  const GetAllChildrenLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(isLoadingChildren: true);
}

final class GetAllChildrenSuccess extends ChildState {
  const GetAllChildrenSuccess(
    List<ChildEntity> children, {
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(children: children, isLoadingChildren: false);
}

final class GetAllChildrenFailure extends ChildState {
  const GetAllChildrenFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(childrenError: message, isLoadingChildren: false);
}

final class GetAllContactsLoading extends ChildState {
  const GetAllContactsLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(isLoadingContacts: true);
}

final class GetAllContactsSuccess extends ChildState {
  const GetAllContactsSuccess(
    List<ContactEntity> contacts, {
    super.children,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(contacts: contacts, isLoadingContacts: false);
}

final class GetAllContactsFailure extends ChildState {
  const GetAllContactsFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(contactsError: message, isLoadingContacts: false);
}

final class GetAllDietaryRestrictionsLoading extends ChildState {
  const GetAllDietaryRestrictionsLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingMedications,
  }) : super(isLoadingDietaryRestrictions: true);
}

final class GetAllDietaryRestrictionsSuccess extends ChildState {
  const GetAllDietaryRestrictionsSuccess(
    List<DietaryRestrictionEntity> dietaryRestrictions, {
    super.children,
    super.contacts,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingMedications,
  }) : super(
          dietaryRestrictions: dietaryRestrictions,
          isLoadingDietaryRestrictions: false,
        );
}

final class GetAllDietaryRestrictionsFailure extends ChildState {
  const GetAllDietaryRestrictionsFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingMedications,
  }) : super(
          dietaryRestrictionsError: message,
          isLoadingDietaryRestrictions: false,
        );
}

final class GetAllMedicationsLoading extends ChildState {
  const GetAllMedicationsLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
  }) : super(isLoadingMedications: true);
}

final class GetAllMedicationsSuccess extends ChildState {
  const GetAllMedicationsSuccess(
    List<MedicationEntity> medications, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
  }) : super(medications: medications, isLoadingMedications: false);
}

final class GetAllMedicationsFailure extends ChildState {
  const GetAllMedicationsFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
  }) : super(medicationsError: message, isLoadingMedications: false);
}

final class GetAllPhysicalRequirementsLoading extends ChildState {
  const GetAllPhysicalRequirementsLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.reportableDiseases,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingReportableDiseases,
  }) : super(isLoadingPhysicalRequirements: true);
}

final class GetAllPhysicalRequirementsSuccess extends ChildState {
  const GetAllPhysicalRequirementsSuccess(
    List<PhysicalRequirementEntity> physicalRequirements, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.reportableDiseases,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingReportableDiseases,
  }) : super(
          physicalRequirements: physicalRequirements,
          isLoadingPhysicalRequirements: false,
        );
}

final class GetAllPhysicalRequirementsFailure extends ChildState {
  const GetAllPhysicalRequirementsFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.reportableDiseases,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingReportableDiseases,
  }) : super(
          physicalRequirementsError: message,
          isLoadingPhysicalRequirements: false,
        );
}

final class GetAllReportableDiseasesLoading extends ChildState {
  const GetAllReportableDiseasesLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.reportableDiseases,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingPhysicalRequirements,
  }) : super(isLoadingReportableDiseases: true);
}

final class GetAllReportableDiseasesSuccess extends ChildState {
  const GetAllReportableDiseasesSuccess(
    List<ReportableDiseaseEntity> reportableDiseases, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingPhysicalRequirements,
  }) : super(
          reportableDiseases: reportableDiseases,
          isLoadingReportableDiseases: false,
        );
}

final class GetAllReportableDiseasesFailure extends ChildState {
  const GetAllReportableDiseasesFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.reportableDiseases,
    super.immunizations,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingPhysicalRequirements,
    super.isLoadingImmunizations,
  }) : super(
          reportableDiseasesError: message,
          isLoadingReportableDiseases: false,
        );
}

final class GetAllImmunizationsLoading extends ChildState {
  const GetAllImmunizationsLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.reportableDiseases,
    super.immunizations,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingPhysicalRequirements,
    super.isLoadingReportableDiseases,
  }) : super(isLoadingImmunizations: true);
}

final class GetAllImmunizationsSuccess extends ChildState {
  const GetAllImmunizationsSuccess(
    List<ImmunizationEntity> immunizations, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.reportableDiseases,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingPhysicalRequirements,
    super.isLoadingReportableDiseases,
  }) : super(immunizations: immunizations, isLoadingImmunizations: false);
}

final class GetAllImmunizationsFailure extends ChildState {
  const GetAllImmunizationsFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.physicalRequirements,
    super.reportableDiseases,
    super.immunizations,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
    super.isLoadingPhysicalRequirements,
    super.isLoadingReportableDiseases,
  }) : super(immunizationsError: message, isLoadingImmunizations: false);
}

final class GetChildByIdLoading extends ChildState {
  const GetChildByIdLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.child,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(isLoadingChild: true);
}

final class GetChildByIdSuccess extends ChildState {
  const GetChildByIdSuccess(
    ChildEntity child, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(child: child, isLoadingChild: false);
}

final class GetChildByIdFailure extends ChildState {
  const GetChildByIdFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.child,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(childError: message, isLoadingChild: false);
}

final class GetChildByContactIdLoading extends ChildState {
  const GetChildByContactIdLoading({
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.child,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(isLoadingChild: true);
}

final class GetChildByContactIdSuccess extends ChildState {
  const GetChildByContactIdSuccess(
    ChildEntity child, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(child: child, isLoadingChild: false);
}

final class GetChildByContactIdFailure extends ChildState {
  const GetChildByContactIdFailure(
    String message, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.child,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(childError: message, isLoadingChild: false);
}
