import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/personal_information/domain/entity/staff_schedule_entity.dart';

@immutable
class StaffScheduleModel extends StaffScheduleEntity {
  const StaffScheduleModel({
    super.id,
    super.staffId,
    super.startDate,
    super.endDate,
    super.shiftDateId,
    super.dateCreated,
    super.dateUpdated,
  });

  factory StaffScheduleModel.fromJson(Map<String, dynamic> json) {
    return StaffScheduleModel(
      id: json['id'] as String?,
      staffId: json['staff_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      shiftDateId: json['shift_date_id'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
    );
  }
}
