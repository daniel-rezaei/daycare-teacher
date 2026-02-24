import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_entity.dart';

@immutable
class ChildModel extends ChildEntity {
  const ChildModel({
    super.id,
    super.policyAcknowledged,
    super.custodyArrangements,
    super.tags,
    super.language,
    super.sleepArrangements,
    super.generalTemperament,
    super.speechDevelopment,
    super.status,
    super.notes,
    super.dob,
    super.dateUpdated,
    super.dateCreated,
    super.primaryRoomId,
    super.contactId,
    super.photo,
    super.userUpdated,
    super.userCreated,
    super.guardians,
    super.classHistory,
    super.guardianRelation,
    super.emergencyContacts,
    super.allergyId,
    super.reportableDiseasesId,
    super.immunizationId,
    super.dietaryRestrictionsId,
    super.physicalRequirementId,
    super.medicationId,
    super.childScheduleId,
    super.subsidyAccountId,
    super.assessment,
    super.accidentReports,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String?,
      policyAcknowledged: json['Policy_Acknowledged'] as bool?,
      custodyArrangements: json['CustodyArrangements'],
      tags: json['Tags'],
      language: json['Language'] != null
          ? (json['Language'] as List).map((e) => e.toString()).toList()
          : null,
      sleepArrangements: json['SleepArrangements'],
      generalTemperament: json['GeneralTemperament'],
      speechDevelopment: json['SpeechDevelopment'],
      status: json['Status'] as String?,
      notes: json['notes'],
      dob: json['dob'] as String?,
      dateUpdated: json['date_updated'] as String?,
      dateCreated: json['date_created'] as String?,
      primaryRoomId: json['primary_room_id'] as String?,
      contactId: json['contact_id'] as String?,
      photo: json['photo'],
      userUpdated: json['user_updated'] as String?,
      userCreated: json['user_created'] as String?,
      guardians: json['guardians'],
      classHistory: json['class_history'],
      guardianRelation: json['guardian_relation'],
      emergencyContacts: json['emergency_contacts'],
      allergyId: json['allergy_id'],
      reportableDiseasesId: json['reportable_diseases_id'],
      immunizationId: json['immunization_id'],
      dietaryRestrictionsId: json['dietary_restrictions_id'],
      physicalRequirementId: json['physical_requirement_id'],
      medicationId: json['medication_id'],
      childScheduleId: json['child_schedule_id'],
      subsidyAccountId: json['subsidy_account_id'],
      assessment: json['assessment'],
      accidentReports: json['accident_reports'],
    );
  }
}
