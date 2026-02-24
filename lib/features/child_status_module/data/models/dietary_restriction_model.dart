import 'package:teacher_app/features/child_status_module/domain/entity/dietary_restriction_entity.dart';

class DietaryRestrictionModel extends DietaryRestrictionEntity {
  const DietaryRestrictionModel({
    super.id,
    super.restrictionName,
    super.childId,
    super.dateCreated,
    super.dateUpdated,
    super.userCreated,
    super.userUpdated,
  });

  factory DietaryRestrictionModel.fromJson(Map<String, dynamic> json) {
    final restrictionName = json['restriction_name'] as String? ??
        json['RestrictionName'] as String?;

    return DietaryRestrictionModel(
      id: json['id'] as String?,
      restrictionName: restrictionName,
      childId: json['child_id'] as String? ?? json['ChildId'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
    );
  }
}
