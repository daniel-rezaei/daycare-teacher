import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';

abstract class ProfileRepository {
  Future<DataState<ContactEntity>> getContact({required String id});
}
