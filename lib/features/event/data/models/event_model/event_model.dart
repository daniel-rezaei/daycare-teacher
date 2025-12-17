import 'package:teacher_app/features/event/domain/entity/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    super.id,
    super.allDay,
    super.description,
    super.eventType,
    super.location,
    super.status,
    super.title,
    super.startAt,
    super.endAt,
    super.dateCreated,
    super.userCreated,
    super.staffId,
    super.childId,
    super.classId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int?,
      allDay: json['all_day'] as bool?,
      description: json['description'] as String?,
      eventType: json['event_type'] as String?,
      location: json['location'] as String?,
      status: json['status'] as String?,
      title: json['title'] as String?,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      dateCreated: json['date_created'] as String?,
      userCreated: json['user_created'] as String?,
      staffId: json['staff_id'] as String?,
      childId: json['child_id'] as List<dynamic>?,
      classId: json['class_id'] as List<dynamic>?,
    );
  }
}

