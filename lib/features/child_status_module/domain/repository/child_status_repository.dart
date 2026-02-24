import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_status_aggregate_entity.dart';

abstract class ChildStatusRepository {
  Future<DataState<ChildStatusAggregateEntity>> getChildrenStatus(
    String classId,
  );
}
