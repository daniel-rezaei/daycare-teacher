import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_emergency_contact_entity.dart';

@immutable
class ChildEmergencyContactModel extends ChildEmergencyContactEntity {
  const ChildEmergencyContactModel({
    super.id,
    super.childId,
    super.contactId,
    super.relationToChild,
    super.isActive,
    super.note,
    super.updatedAt,
    super.endDate,
    super.startDate,
    super.dateCreated,
    super.dateUpdated,
  });

  factory ChildEmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return ChildEmergencyContactModel(
      id: json['id'] as String?,
      childId: json['child_id'] as String?,
      contactId: json['contact_id'] as String?,
      relationToChild: json['relation_to_child'] as String?,
      isActive: json['is_active'] as bool?,
      note: json['note'] as String?,
      updatedAt: json['updated_at'] as String?,
      endDate: json['end_date'] as String?,
      startDate: json['start_date'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
    );
  }
}
