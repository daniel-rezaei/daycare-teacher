import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/domain/repository/child_repository.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

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
}

