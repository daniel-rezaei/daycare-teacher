import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_emergency_contact_entity.dart';

abstract class ChildEmergencyContactRepository {
  Future<DataState<List<ChildEmergencyContactEntity>>>
      getAllChildEmergencyContacts();
}
