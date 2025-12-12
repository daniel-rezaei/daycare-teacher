import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';

class StaffClassModel extends StaffClassEntity {
  const StaffClassModel({
    super.id,
    super.role,
    super.note,
    super.dateCreated,
    super.dateUpdated,
    super.userCreated,
    super.userUpdated,
    super.staffIds,
    super.classIds,
  });

  factory StaffClassModel.fromJson(Map<String, dynamic> json) {
    return StaffClassModel(
      id: json['id'] as String?,
      role: json['Role'] as String?,
      note: json['Note'] as String?,
      dateCreated: json['date_created'] != null
          ? DateTime.tryParse(json['date_created'])
          : null,
      dateUpdated: json['date_updated'] != null
          ? DateTime.tryParse(json['date_updated'])
          : null,
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
      staffIds: (json['staff_id'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      classIds: (json['class_id'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Role': role,
      'Note': note,
      'date_created': dateCreated?.toIso8601String(),
      'date_updated': dateUpdated?.toIso8601String(),
      'user_created': userCreated,
      'user_updated': userUpdated,
      'staff_id': staffIds,
      'class_id': classIds,
    };
  }
}
