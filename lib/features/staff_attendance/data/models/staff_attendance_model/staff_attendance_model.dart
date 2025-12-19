import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';

@immutable
class StaffAttendanceModel extends StaffAttendanceEntity {
  const StaffAttendanceModel({
    super.id,
    super.staffId,
    super.classId,
    super.eventAt,
    super.eventType,
    super.dateCreated,
    super.dateUpdated,
  });

  factory StaffAttendanceModel.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceModel(
      id: json['id'] as String?,
      staffId: json['staff_id'] as String?,
      classId: json['class_id'] as String?,
      eventAt: json['event_at'] as String?,
      eventType: json['event_type'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
    );
  }
}

