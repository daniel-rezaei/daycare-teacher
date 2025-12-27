import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child/domain/usecase/child_usecase.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
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
    debugPrint('[CHILD_PROFILE_BLOC] Starting preload for childId: ${event.childId}');
    emit(const ChildProfileLoading());

    try {
      // Load all medical data in parallel
      final results = await Future.wait([
        childUsecase.getAllDietaryRestrictions(),
        childUsecase.getAllMedications(),
        childUsecase.getAllPhysicalRequirements(),
        childUsecase.getAllReportableDiseases(),
      ]);

      // Extract data from results
      List<DietaryRestrictionEntity>? dietaryRestrictions;
      List<MedicationEntity>? medications;
      List<PhysicalRequirementEntity>? physicalRequirements;
      List<ReportableDiseaseEntity>? reportableDiseases;

      // Process dietary restrictions
      if (results[0] is DataSuccess) {
        dietaryRestrictions = (results[0] as DataSuccess).data;
        debugPrint('[CHILD_PROFILE_BLOC] Loaded ${dietaryRestrictions?.length ?? 0} dietary restrictions');
      } else {
        debugPrint('[CHILD_PROFILE_BLOC] Failed to load dietary restrictions: ${(results[0] as DataFailed).error}');
      }

      // Process medications
      if (results[1] is DataSuccess) {
        medications = (results[1] as DataSuccess).data;
        debugPrint('[CHILD_PROFILE_BLOC] Loaded ${medications?.length ?? 0} medications');
      } else {
        debugPrint('[CHILD_PROFILE_BLOC] Failed to load medications: ${(results[1] as DataFailed).error}');
      }

      // Process physical requirements
      if (results[2] is DataSuccess) {
        physicalRequirements = (results[2] as DataSuccess).data;
        debugPrint('[CHILD_PROFILE_BLOC] Loaded ${physicalRequirements?.length ?? 0} physical requirements');
      } else {
        debugPrint('[CHILD_PROFILE_BLOC] Failed to load physical requirements: ${(results[2] as DataFailed).error}');
      }

      // Process reportable diseases
      if (results[3] is DataSuccess) {
        reportableDiseases = (results[3] as DataSuccess).data;
        debugPrint('[CHILD_PROFILE_BLOC] Loaded ${reportableDiseases?.length ?? 0} reportable diseases');
      } else {
        debugPrint('[CHILD_PROFILE_BLOC] Failed to load reportable diseases: ${(results[3] as DataFailed).error}');
      }

      // Filter data for the specific childId
      final filteredDietaryRestrictions = dietaryRestrictions
              ?.where((dr) => dr.childId == event.childId)
              .toList() ??
          [];
      final filteredMedications = medications
              ?.where((m) => m.childId == event.childId)
              .toList() ??
          [];
      final filteredPhysicalRequirements = physicalRequirements
              ?.where((pr) => pr.childId == event.childId)
              .toList() ??
          [];
      final filteredReportableDiseases = reportableDiseases
              ?.where((rd) => rd.childId == event.childId)
              .toList() ??
          [];

      debugPrint('[CHILD_PROFILE_BLOC] Filtered data for childId ${event.childId}:');
      debugPrint('[CHILD_PROFILE_BLOC] - Dietary Restrictions: ${filteredDietaryRestrictions.length}');
      debugPrint('[CHILD_PROFILE_BLOC] - Medications: ${filteredMedications.length}');
      debugPrint('[CHILD_PROFILE_BLOC] - Physical Requirements: ${filteredPhysicalRequirements.length}');
      debugPrint('[CHILD_PROFILE_BLOC] - Reportable Diseases: ${filteredReportableDiseases.length}');

      // Emit success state with filtered data
      emit(ChildProfileDataLoaded(
        childId: event.childId,
        dietaryRestrictions: filteredDietaryRestrictions,
        medications: filteredMedications,
        physicalRequirements: filteredPhysicalRequirements,
        reportableDiseases: filteredReportableDiseases,
      ));
    } catch (e, stackTrace) {
      debugPrint('[CHILD_PROFILE_BLOC] Exception during preload: $e');
      debugPrint('[CHILD_PROFILE_BLOC] Stack trace: $stackTrace');
      emit(ChildProfileError('Failed to load medical data: $e'));
    }
  }

  FutureOr<void> _clearChildProfileDataEvent(
    ClearChildProfileDataEvent event,
    Emitter<ChildProfileState> emit,
  ) {
    debugPrint('[CHILD_PROFILE_BLOC] Clearing child profile data');
    emit(const ChildProfileInitial());
  }
}

