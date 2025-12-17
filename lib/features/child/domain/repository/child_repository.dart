import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

abstract class ChildRepository {
  // دریافت همه بچه‌ها
  Future<DataState<List<ChildEntity>>> getAllChildren();

  // دریافت همه Contacts
  Future<DataState<List<ContactEntity>>> getAllContacts();
}

