import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';

class AttendanceChildModel extends AttendanceChildEntity {
  const AttendanceChildModel({
    super.id,
    super.checkInAt,
    super.checkOutAt,
    super.childId,
    super.classId,
    super.staffId,
    super.checkInMethod,
    super.checkOutMethod,
    super.notes,
  });

  factory AttendanceChildModel.fromJson(Map<String, dynamic> json) {
    return AttendanceChildModel(
      id: json['id'] as String?,
      checkInAt: json['check_in_at'] as String?,
      checkOutAt: json['check_out_at'] as String?,
      childId: json['child_id'] as String?,
      classId: json['class_id'] as String?,
      staffId: json['staff_id'] as String?,
      checkInMethod: json['check_in_method'] as String?,
      checkOutMethod: json['check_out_method'] as String?,
      notes: json['Notes'] as String?, // API از 'Notes' استفاده می‌کند
    );
  }
}

