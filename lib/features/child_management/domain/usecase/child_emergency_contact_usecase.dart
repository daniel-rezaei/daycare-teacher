import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_emergency_contact_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_emergency_contact_repository.dart';

@singleton
class ChildEmergencyContactUsecase {
  final ChildEmergencyContactRepository childEmergencyContactRepository;

  ChildEmergencyContactUsecase(this.childEmergencyContactRepository);

  Future<DataState<List<ChildEmergencyContactEntity>>>
      getAllChildEmergencyContacts() async {
    return await childEmergencyContactRepository.getAllChildEmergencyContacts();
  }
}
