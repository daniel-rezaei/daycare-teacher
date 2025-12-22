import 'package:teacher_app/features/immunization/domain/entity/immunization_entity.dart';

class ImmunizationModel extends ImmunizationEntity {
  const ImmunizationModel({
    super.id,
    super.vaccineName,
    super.childId,
    super.dateCreated,
    super.dateUpdated,
    super.userCreated,
    super.userUpdated,
  });

  factory ImmunizationModel.fromJson(Map<String, dynamic> json) {
    return ImmunizationModel(
      id: json['id'] as String?,
      vaccineName: json['vaccine_name'] as String?,
      childId: json['child_id'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
    );
  }
}

