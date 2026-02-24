import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/allergy_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/reportable_disease_entity.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';

abstract class ChildRepository {
  Future<DataState<List<ChildEntity>>> getAllChildren();
  Future<DataState<List<ContactEntity>>> getAllContacts();
  Future<DataState<List<DietaryRestrictionEntity>>> getAllDietaryRestrictions();
  Future<DataState<List<MedicationEntity>>> getAllMedications();
  Future<DataState<List<PhysicalRequirementEntity>>> getAllPhysicalRequirements();
  Future<DataState<List<ReportableDiseaseEntity>>> getAllReportableDiseases();
  Future<DataState<List<ImmunizationEntity>>> getAllImmunizations();
  Future<DataState<List<AllergyEntity>>> getAllAllergies();
  Future<DataState<ChildEntity>> getChildById({required String childId});
  Future<DataState<ChildEntity>> getChildByContactId({required String contactId});
}
