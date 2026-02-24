import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final int? id;
  final bool? allDay;
  final String? description;
  final String? eventType;
  final String? location;
  final String? status;
  final String? title;
  final String? startAt;
  final String? endAt;
  final String? dateCreated;
  final String? userCreated;
  final String? staffId;
  final List<dynamic>? childId;
  final List<dynamic>? classId;

  const EventEntity({
    this.id,
    this.allDay,
    this.description,
    this.eventType,
    this.location,
    this.status,
    this.title,
    this.startAt,
    this.endAt,
    this.dateCreated,
    this.userCreated,
    this.staffId,
    this.childId,
    this.classId,
  });

  @override
  List<Object?> get props => [
        id,
        allDay,
        description,
        eventType,
        location,
        status,
        title,
        startAt,
        endAt,
        dateCreated,
        userCreated,
        staffId,
        childId,
        classId,
      ];
}
