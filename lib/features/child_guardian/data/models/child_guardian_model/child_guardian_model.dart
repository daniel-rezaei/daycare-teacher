import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/child_guardian/domain/entity/child_guardian_entity.dart';

@immutable
class ChildGuardianModel extends ChildGuardianEntity {
  const ChildGuardianModel({
    super.id,
    super.childId,
    super.contactId,
    super.relation,
    super.pickupAuthorized,
    super.dateCreated,
    super.dateUpdated,
  });

  factory ChildGuardianModel.fromJson(Map<String, dynamic> json) {
    return ChildGuardianModel(
      id: json['id'] as String?,
      childId: json['child_id'] as String?,
      contactId: json['contact_id'] as String?,
      relation: json['relation'] as String?,
      pickupAuthorized: json['pickup_authorized'] as bool?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
    );
  }
}

