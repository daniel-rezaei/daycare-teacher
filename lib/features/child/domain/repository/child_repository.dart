import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

abstract class ChildRepository {
  // دریافت همه بچه‌ها
  Future<DataState<List<ChildEntity>>> getAllChildren();

  // دریافت همه Contacts
  Future<DataState<List<ContactEntity>>> getAllContacts();

  // دریافت همه محدودیت‌های غذایی
  Future<DataState<List<DietaryRestrictionEntity>>> getAllDietaryRestrictions();

  // دریافت همه داروها
  Future<DataState<List<MedicationEntity>>> getAllMedications();
}

