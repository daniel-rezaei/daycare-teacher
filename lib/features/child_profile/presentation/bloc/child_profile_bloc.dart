import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/allergy/domain/entity/allergy_entity.dart';
import 'package:teacher_app/features/child/domain/usecase/child_usecase.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/immunization/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/reportable_disease/domain/entity/reportable_disease_entity.dart';

part 'child_profile_event.dart';
part 'child_profile_state.dart';

/// Dedicated bloc for Child Profile that preloads all medical data
/// This ensures all medical data is loaded BEFORE navigation to Child Profile
@injectable
class ChildProfileBloc extends Bloc<ChildProfileEvent, ChildProfileState> {
  final ChildUsecase childUsecase;

  ChildProfileBloc(this.childUsecase) : super(const ChildProfileInitial()) {
    on<PreloadChildMedicalDataEvent>(_preloadChildMedicalDataEvent);
    on<ClearChildProfileDataEvent>(_clearChildProfileDataEvent);
  }

  /// Preload all medical data for a specific childId
  /// This should be called BEFORE navigating to Child Profile
  FutureOr<void> _preloadChildMedicalDataEvent(
    PreloadChildMedicalDataEvent event,
    Emitter<ChildProfileState> emit,
  ) async {
    emit(const ChildProfileLoading());

    try {
      final results = await Future.wait([
        childUsecase.getAllAllergies(),
        childUsecase.getAllDietaryRestrictions(),
        childUsecase.getAllMedications(),
        childUsecase.getAllImmunizations(),
        childUsecase.getAllPhysicalRequirements(),
        childUsecase.getAllReportableDiseases(),
      ]);

      // Extract data from results
      List<AllergyEntity>? allergies;
      List<DietaryRestrictionEntity>? dietaryRestrictions;
      List<MedicationEntity>? medications;
      List<ImmunizationEntity>? immunizations;
      List<PhysicalRequirementEntity>? physicalRequirements;
      List<ReportableDiseaseEntity>? reportableDiseases;

      // Process allergies
      if (results[0] is DataSuccess) {
        allergies = (results[0] as DataSuccess).data;
      }

      // Process dietary restrictions
      if (results[1] is DataSuccess) {
        dietaryRestrictions = (results[1] as DataSuccess).data;
      }

      // Process medications
      if (results[2] is DataSuccess) {
        medications = (results[2] as DataSuccess).data;
      }

      // Process immunizations
      if (results[3] is DataSuccess) {
        immunizations = (results[3] as DataSuccess).data;
      }

      // Process physical requirements
      if (results[4] is DataSuccess) {
        physicalRequirements = (results[4] as DataSuccess).data;
      }

      // Process reportable diseases
      if (results[5] is DataSuccess) {
        reportableDiseases = (results[5] as DataSuccess).data;
      }

      // Filter data for the specific childId
      final filteredAllergies =
          allergies?.where((a) => a.childId == event.childId).toList() ?? [];
      final filteredDietaryRestrictions =
          dietaryRestrictions
              ?.where((dr) => dr.childId == event.childId)
              .toList() ??
          [];
      final filteredMedications =
          medications?.where((m) => m.childId == event.childId).toList() ?? [];
      final filteredImmunizations =
          immunizations?.where((i) => i.childId == event.childId).toList() ??
          [];
      final filteredPhysicalRequirements =
          physicalRequirements
              ?.where((pr) => pr.childId == event.childId)
              .toList() ??
          [];
      final filteredReportableDiseases =
          reportableDiseases
              ?.where((rd) => rd.childId == event.childId)
              .toList() ??
          [];

      // Emit success state with filtered data
      emit(
        ChildProfileDataLoaded(
          childId: event.childId,
          allergies: filteredAllergies,
          dietaryRestrictions: filteredDietaryRestrictions,
          medications: filteredMedications,
          immunizations: filteredImmunizations,
          physicalRequirements: filteredPhysicalRequirements,
          reportableDiseases: filteredReportableDiseases,
        ),
      );
    } catch (e) {
      emit(ChildProfileError('Failed to load medical data: $e'));
    }
  }

  FutureOr<void> _clearChildProfileDataEvent(
    ClearChildProfileDataEvent event,
    Emitter<ChildProfileState> emit,
  ) {
    emit(const ChildProfileInitial());
  }
}
