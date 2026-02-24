import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_status_aggregate_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/repository/child_status_repository.dart';

@singleton
class ChildStatusUsecase {
  final ChildStatusRepository childStatusRepository;

  ChildStatusUsecase(this.childStatusRepository);

  Future<DataState<ChildStatusAggregateEntity>> getChildrenStatus(
    String classId,
  ) async {
    return childStatusRepository.getChildrenStatus(classId);
  }
}
