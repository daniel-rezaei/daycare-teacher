import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

abstract class ProfileRepository {
  // دریافت اطلاعات تماس
  Future<DataState<ContactEntity>> getContact({required String id});
}

