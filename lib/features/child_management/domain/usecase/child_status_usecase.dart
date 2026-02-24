import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_status_aggregate_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_status_repository.dart';

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
