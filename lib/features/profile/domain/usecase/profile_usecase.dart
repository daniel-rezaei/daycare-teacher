import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/profile/domain/repository/profile_repository.dart';

@singleton
class ProfileUsecase {
  final ProfileRepository profileRepository;

  ProfileUsecase(this.profileRepository);

  // دریافت اطلاعات تماس
  Future<DataState<ContactEntity>> getContact({required String id}) async {
    return await profileRepository.getContact(id: id);
  }
}

