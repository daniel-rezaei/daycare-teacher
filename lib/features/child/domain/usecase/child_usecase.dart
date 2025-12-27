import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/allergy/domain/entity/allergy_entity.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/domain/repository/child_repository.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/immunization/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/reportable_disease/domain/entity/reportable_disease_entity.dart';

@singleton
class ChildUsecase {
  final ChildRepository childRepository;

  ChildUsecase(this.childRepository);

  // دریافت همه بچه‌ها
  Future<DataState<List<ChildEntity>>> getAllChildren() async {
    return await childRepository.getAllChildren();
  }

  // دریافت همه Contacts
  Future<DataState<List<ContactEntity>>> getAllContacts() async {
    return await childRepository.getAllContacts();
  }

  // دریافت همه محدودیت‌های غذایی
  Future<DataState<List<DietaryRestrictionEntity>>> getAllDietaryRestrictions() async {
    return await childRepository.getAllDietaryRestrictions();
  }

  // دریافت همه داروها
  Future<DataState<List<MedicationEntity>>> getAllMedications() async {
    return await childRepository.getAllMedications();
  }

  // دریافت همه نیازمندی‌های فیزیکی
  Future<DataState<List<PhysicalRequirementEntity>>> getAllPhysicalRequirements() async {
    return await childRepository.getAllPhysicalRequirements();
  }

  // دریافت همه بیماری‌های قابل گزارش
  Future<DataState<List<ReportableDiseaseEntity>>> getAllReportableDiseases() async {
    return await childRepository.getAllReportableDiseases();
  }

  // دریافت همه واکسیناسیون‌ها
  Future<DataState<List<ImmunizationEntity>>> getAllImmunizations() async {
    return await childRepository.getAllImmunizations();
  }

  // دریافت همه آلرژی‌ها
  Future<DataState<List<AllergyEntity>>> getAllAllergies() async {
    return await childRepository.getAllAllergies();
  }

  // دریافت بچه بر اساس ID
  Future<DataState<ChildEntity>> getChildById({required String childId}) async {
    return await childRepository.getChildById(childId: childId);
  }

  // دریافت بچه بر اساس contact_id
  Future<DataState<ChildEntity>> getChildByContactId({required String contactId}) async {
    return await childRepository.getChildByContactId(contactId: contactId);
  }
}

