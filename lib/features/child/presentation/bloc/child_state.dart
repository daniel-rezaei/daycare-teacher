part of 'child_bloc.dart';

sealed class ChildState extends Equatable {
  final List<ChildEntity>? children;
  final List<ContactEntity>? contacts;
  final List<DietaryRestrictionEntity>? dietaryRestrictions;
  final List<MedicationEntity>? medications;
  final bool isLoadingChildren;
  final bool isLoadingContacts;
  final bool isLoadingDietaryRestrictions;
  final bool isLoadingMedications;
  final String? childrenError;
  final String? contactsError;
  final String? dietaryRestrictionsError;
  final String? medicationsError;

  const ChildState({
    this.children,
    this.contacts,
    this.dietaryRestrictions,
    this.medications,
    this.isLoadingChildren = false,
    this.isLoadingContacts = false,
    this.isLoadingDietaryRestrictions = false,
    this.isLoadingMedications = false,
    this.childrenError,
    this.contactsError,
    this.dietaryRestrictionsError,
    this.medicationsError,
  });

  @override
  List<Object?> get props => [
        children,
        contacts,
        dietaryRestrictions,
        medications,
        isLoadingChildren,
        isLoadingContacts,
        isLoadingDietaryRestrictions,
        isLoadingMedications,
        childrenError,
        contactsError,
        dietaryRestrictionsError,
        medicationsError,
      ];
}

final class ChildInitial extends ChildState {
  const ChildInitial();
}

/// Loading state for getting all children
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

/// Success state for getting all children
final class GetAllChildrenSuccess extends ChildState {
  const GetAllChildrenSuccess(
    List<ChildEntity> children, {
    super.contacts,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(
          children: children,
          isLoadingChildren: false,
        );
}

/// Failure state for getting all children
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
  }) : super(
          childrenError: message,
          isLoadingChildren: false,
        );
}

/// Loading state for getting all contacts
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

/// Success state for getting all contacts
final class GetAllContactsSuccess extends ChildState {
  const GetAllContactsSuccess(
    List<ContactEntity> contacts, {
    super.children,
    super.dietaryRestrictions,
    super.medications,
    super.isLoadingChildren,
    super.isLoadingDietaryRestrictions,
    super.isLoadingMedications,
  }) : super(
          contacts: contacts,
          isLoadingContacts: false,
        );
}

/// Failure state for getting all contacts
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
  }) : super(
          contactsError: message,
          isLoadingContacts: false,
        );
}

/// Loading state for getting all dietary restrictions
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

/// Success state for getting all dietary restrictions
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

/// Failure state for getting all dietary restrictions
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

/// Loading state for getting all medications
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

/// Success state for getting all medications
final class GetAllMedicationsSuccess extends ChildState {
  const GetAllMedicationsSuccess(
    List<MedicationEntity> medications, {
    super.children,
    super.contacts,
    super.dietaryRestrictions,
    super.isLoadingChildren,
    super.isLoadingContacts,
    super.isLoadingDietaryRestrictions,
  }) : super(
          medications: medications,
          isLoadingMedications: false,
        );
}

/// Failure state for getting all medications
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
  }) : super(
          medicationsError: message,
          isLoadingMedications: false,
        );
}

