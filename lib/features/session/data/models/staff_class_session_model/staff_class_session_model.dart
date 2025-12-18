import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';

class StaffClassSessionModel extends StaffClassSessionEntity {
  const StaffClassSessionModel({
    super.id,
    super.startAt,
    super.endAt,
    super.staffId,
    super.classId,
  });

  factory StaffClassSessionModel.fromJson(Map<String, dynamic> json) {
    return StaffClassSessionModel(
      id: json['id'] as String?,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      staffId: json['staff_id'] as String?,
      classId: json['class_id'] as String?,
    );
  }
}


