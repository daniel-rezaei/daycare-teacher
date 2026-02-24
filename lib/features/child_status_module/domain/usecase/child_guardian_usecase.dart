import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_guardian_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/repository/child_guardian_repository.dart';

@singleton
class ChildGuardianUsecase {
  final ChildGuardianRepository childGuardianRepository;

  ChildGuardianUsecase(this.childGuardianRepository);

  Future<DataState<List<ChildGuardianEntity>>> getChildGuardianByChildId({
    required String childId,
  }) async {
    return await childGuardianRepository.getChildGuardianByChildId(
      childId: childId,
    );
  }
}
