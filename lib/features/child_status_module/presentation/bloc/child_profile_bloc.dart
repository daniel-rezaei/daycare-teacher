import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/usecase/child_usecase.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/allergy_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/reportable_disease_entity.dart';

part 'child_profile_event.dart';
part 'child_profile_state.dart';

@injectable
class ChildProfileBloc extends Bloc<ChildProfileEvent, ChildProfileState> {
  final ChildUsecase childUsecase;

  ChildProfileBloc(this.childUsecase) : super(const ChildProfileInitial()) {
    on<PreloadChildMedicalDataEvent>(_preloadChildMedicalDataEvent);
    on<ClearChildProfileDataEvent>(_clearChildProfileDataEvent);
  }

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

      List<AllergyEntity>? allergies;
      List<DietaryRestrictionEntity>? dietaryRestrictions;
      List<MedicationEntity>? medications;
      List<ImmunizationEntity>? immunizations;
      List<PhysicalRequirementEntity>? physicalRequirements;
      List<ReportableDiseaseEntity>? reportableDiseases;

      if (results[0] is DataSuccess) {
        allergies = (results[0] as DataSuccess).data;
      }
      if (results[1] is DataSuccess) {
        dietaryRestrictions = (results[1] as DataSuccess).data;
      }
      if (results[2] is DataSuccess) {
        medications = (results[2] as DataSuccess).data;
      }
      if (results[3] is DataSuccess) {
        immunizations = (results[3] as DataSuccess).data;
      }
      if (results[4] is DataSuccess) {
        physicalRequirements = (results[4] as DataSuccess).data;
      }
      if (results[5] is DataSuccess) {
        reportableDiseases = (results[5] as DataSuccess).data;
      }

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
