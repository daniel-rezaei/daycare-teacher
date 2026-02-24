import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_guardian_entity.dart';

abstract class ChildGuardianRepository {
  Future<DataState<List<ChildGuardianEntity>>> getChildGuardianByChildId({
    required String childId,
  });
}
