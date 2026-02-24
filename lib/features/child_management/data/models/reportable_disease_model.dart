import 'package:teacher_app/features/child_management/domain/entity/reportable_disease_entity.dart';

class ReportableDiseaseModel extends ReportableDiseaseEntity {
  const ReportableDiseaseModel({
    super.id,
    super.diseaseName,
    super.childId,
    super.dateCreated,
    super.dateUpdated,
    super.userCreated,
    super.userUpdated,
  });

  factory ReportableDiseaseModel.fromJson(Map<String, dynamic> json) {
    return ReportableDiseaseModel(
      id: json['id'] as String?,
      diseaseName: json['disease_name'] as String?,
      childId: json['child_id'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
    );
  }
}
