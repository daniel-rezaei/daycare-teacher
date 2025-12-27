part of 'child_profile_bloc.dart';

sealed class ChildProfileState extends Equatable {
  const ChildProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded
final class ChildProfileInitial extends ChildProfileState {
  const ChildProfileInitial();
}

/// Loading state - medical data is being preloaded
final class ChildProfileLoading extends ChildProfileState {
  const ChildProfileLoading();
}

/// Success state - all medical data is loaded and filtered for the child
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

  /// Check if all medical data is loaded
  bool get isFullyLoaded => true; // All data is loaded in this state

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

/// Error state - failed to load medical data
final class ChildProfileError extends ChildProfileState {
  final String message;

  const ChildProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

