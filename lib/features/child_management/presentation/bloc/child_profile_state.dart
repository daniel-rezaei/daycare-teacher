part of 'child_profile_bloc.dart';

sealed class ChildProfileState extends Equatable {
  const ChildProfileState();

  @override
  List<Object?> get props => [];
}

final class ChildProfileInitial extends ChildProfileState {
  const ChildProfileInitial();
}

final class ChildProfileLoading extends ChildProfileState {
  const ChildProfileLoading();
}

final class ChildProfileDataLoaded extends ChildProfileState {
  final String childId;
  final List<AllergyEntity> allergies;
  final List<DietaryRestrictionEntity> dietaryRestrictions;
  final List<MedicationEntity> medications;
  final List<ImmunizationEntity> immunizations;
  final List<PhysicalRequirementEntity> physicalRequirements;
  final List<ReportableDiseaseEntity> reportableDiseases;

  const ChildProfileDataLoaded({
    required this.childId,
    required this.allergies,
    required this.dietaryRestrictions,
    required this.medications,
    required this.immunizations,
    required this.physicalRequirements,
    required this.reportableDiseases,
  });

  bool get isFullyLoaded => true;

  @override
  List<Object?> get props => [
        childId,
        allergies,
        dietaryRestrictions,
        medications,
        immunizations,
        physicalRequirements,
        reportableDiseases,
      ];
}

final class ChildProfileError extends ChildProfileState {
  final String message;

  const ChildProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
