import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/shift_date_entity.dart';

@immutable
class ShiftDateModel extends ShiftDateEntity {
  const ShiftDateModel({
    super.id,
    super.daysOfWeek,
    super.startTime,
    super.endTime,
    super.dateCreated,
    super.dateUpdated,
  });

  factory ShiftDateModel.fromJson(Map<String, dynamic> json) {
    return ShiftDateModel(
      id: json['id'] as String?,
      daysOfWeek: json['days_of_week'] != null
          ? List<String>.from(json['days_of_week'] as List)
          : null,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
    );
  }
}

