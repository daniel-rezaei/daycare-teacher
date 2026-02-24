import 'package:equatable/equatable.dart';

class ChildEntity extends Equatable {
  final String? id;
  final bool? policyAcknowledged;
  final List<dynamic>? custodyArrangements;
  final String? tags;
  final List<String>? language;
  final String? sleepArrangements;
  final String? generalTemperament;
  final String? speechDevelopment;
  final String? status;
  final String? notes;
  final String? dob;
  final String? dateUpdated;
  final String? dateCreated;
  final String? primaryRoomId;
  final String? contactId;
  final String? photo;
  final String? userUpdated;
  final String? userCreated;
  final List<dynamic>? guardians;
  final List<dynamic>? classHistory;
  final List<dynamic>? guardianRelation;
  final List<dynamic>? emergencyContacts;
  final List<dynamic>? allergyId;
  final List<dynamic>? reportableDiseasesId;
  final List<dynamic>? immunizationId;
  final List<dynamic>? dietaryRestrictionsId;
  final List<dynamic>? physicalRequirementId;
  final List<dynamic>? medicationId;
  final List<dynamic>? childScheduleId;
  final List<dynamic>? subsidyAccountId;
  final List<dynamic>? assessment;
  final List<dynamic>? accidentReports;

  const ChildEntity({
    this.id,
    this.policyAcknowledged,
    this.custodyArrangements,
    this.tags,
    this.language,
    this.sleepArrangements,
    this.generalTemperament,
    this.speechDevelopment,
    this.status,
    this.notes,
    this.dob,
    this.dateUpdated,
    this.dateCreated,
    this.primaryRoomId,
    this.contactId,
    this.photo,
    this.userUpdated,
    this.userCreated,
    this.guardians,
    this.classHistory,
    this.guardianRelation,
    this.emergencyContacts,
    this.allergyId,
    this.reportableDiseasesId,
    this.immunizationId,
    this.dietaryRestrictionsId,
    this.physicalRequirementId,
    this.medicationId,
    this.childScheduleId,
    this.subsidyAccountId,
    this.assessment,
    this.accidentReports,
  });

  @override
  List<Object?> get props => [
        id,
        policyAcknowledged,
        custodyArrangements,
        tags,
        language,
        sleepArrangements,
        generalTemperament,
        speechDevelopment,
        status,
        notes,
        dob,
        dateUpdated,
        dateCreated,
        primaryRoomId,
        contactId,
        photo,
        userUpdated,
        userCreated,
        guardians,
        classHistory,
        guardianRelation,
        emergencyContacts,
        allergyId,
        reportableDiseasesId,
        immunizationId,
        dietaryRestrictionsId,
        physicalRequirementId,
        medicationId,
        childScheduleId,
        subsidyAccountId,
        assessment,
        accidentReports,
      ];
}
