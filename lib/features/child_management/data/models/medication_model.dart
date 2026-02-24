import 'package:teacher_app/features/child_management/domain/entity/medication_entity.dart';

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    super.id,
    super.archived,
    super.note,
    super.instructions,
    super.purpose,
    super.timeOfDay,
    super.storageLocation,
    super.storageTemperature,
    super.medicationName,
    super.dose,
    super.endDate,
    super.startDate,
    super.dateUpdated,
    super.dateCreated,
    super.userUpdated,
    super.userCreated,
    super.childId,
    super.consentDocumentId,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as int?,
      archived: json['archived'] as bool?,
      note: json['Note'] as String?,
      instructions: json['instructions'] as String?,
      purpose: json['Purpose'] as String?,
      timeOfDay: json['TimeOfDay'] as String?,
      storageLocation: json['StorageLocation'] as String?,
      storageTemperature: json['StorageTemperature'] as String?,
      medicationName: json['medication_name'] as String?,
      dose: json['dose'] as String?,
      endDate: json['end_date'] as String?,
      startDate: json['start_date'] as String?,
      dateUpdated: json['date_updated'] as String?,
      dateCreated: json['date_created'] as String?,
      userUpdated: json['user_updated'] as String?,
      userCreated: json['user_created'] as String?,
      childId: json['child_id'] as String?,
      consentDocumentId: json['consent_document_id'] as List<dynamic>?,
    );
  }
}
