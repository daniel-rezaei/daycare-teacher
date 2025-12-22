import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';

class PhysicalRequirementModel extends PhysicalRequirementEntity {
  const PhysicalRequirementModel({
    super.id,
    super.requirementName,
    super.childId,
    super.dateCreated,
    super.dateUpdated,
    super.userCreated,
    super.userUpdated,
  });

  factory PhysicalRequirementModel.fromJson(Map<String, dynamic> json) {
    return PhysicalRequirementModel(
      id: json['id'] as String?,
      requirementName: json['requirement_name'] as String?,
      childId: json['child_id'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
    );
  }
}

