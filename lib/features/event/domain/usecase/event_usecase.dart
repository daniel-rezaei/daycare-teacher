import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
import 'package:teacher_app/features/event/domain/repository/event_repository.dart';

@singleton
class EventUsecase {
  final EventRepository eventRepository;

  EventUsecase(this.eventRepository);

  // دریافت لیست همه رویدادها
  Future<DataState<List<EventEntity>>> getAllEvents() async {
    return await eventRepository.getAllEvents();
  }
}

