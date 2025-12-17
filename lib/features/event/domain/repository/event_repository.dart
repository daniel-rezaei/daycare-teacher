import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';

abstract class EventRepository {
  // دریافت لیست همه رویدادها
  Future<DataState<List<EventEntity>>> getAllEvents();
}

