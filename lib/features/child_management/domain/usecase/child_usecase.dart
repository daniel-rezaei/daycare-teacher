import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/allergy_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/reportable_disease_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_repository.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';

@singleton
class ChildUsecase {
  final ChildRepository childRepository;

  ChildUsecase(this.childRepository);

  Future<DataState<List<ChildEntity>>> getAllChildren() async =>
      await childRepository.getAllChildren();

  Future<DataState<List<ContactEntity>>> getAllContacts() async =>
      await childRepository.getAllContacts();

  Future<DataState<List<DietaryRestrictionEntity>>>
      getAllDietaryRestrictions() async =>
      await childRepository.getAllDietaryRestrictions();

  Future<DataState<List<MedicationEntity>>> getAllMedications() async =>
      await childRepository.getAllMedications();

  Future<DataState<List<PhysicalRequirementEntity>>>
      getAllPhysicalRequirements() async =>
      await childRepository.getAllPhysicalRequirements();

  Future<DataState<List<ReportableDiseaseEntity>>>
      getAllReportableDiseases() async =>
      await childRepository.getAllReportableDiseases();

  Future<DataState<List<ImmunizationEntity>>> getAllImmunizations() async =>
      await childRepository.getAllImmunizations();

  Future<DataState<List<AllergyEntity>>> getAllAllergies() async =>
      await childRepository.getAllAllergies();

  Future<DataState<ChildEntity>> getChildById({required String childId}) async =>
      await childRepository.getChildById(childId: childId);

  Future<DataState<ChildEntity>> getChildByContactId(
          {required String contactId}) async =>
      await childRepository.getChildByContactId(contactId: contactId);
}
