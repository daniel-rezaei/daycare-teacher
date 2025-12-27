import 'package:teacher_app/features/allergy/domain/entity/allergy_entity.dart';

class AllergyModel extends AllergyEntity {
  const AllergyModel({
    super.id,
    super.allergenName,
    super.childId,
    super.dateCreated,
    super.dateUpdated,
    super.userCreated,
    super.userUpdated,
  });

  factory AllergyModel.fromJson(Map<String, dynamic> json) {
    return AllergyModel(
      id: json['id'] as String?,
      allergenName: json['allergen_name'] as String?,
      childId: json['child_id'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
    );
  }
}

