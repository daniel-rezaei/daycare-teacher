import 'package:equatable/equatable.dart';

class MedicationEntity extends Equatable {
  final int? id;
  final bool? archived;
  final String? note;
  final String? instructions;
  final String? purpose;
  final String? timeOfDay;
  final String? storageLocation;
  final String? storageTemperature;
  final String? medicationName;
  final String? dose;
  final String? endDate;
  final String? startDate;
  final String? dateUpdated;
  final String? dateCreated;
  final String? userUpdated;
  final String? userCreated;
  final String? childId;
  final List<dynamic>? consentDocumentId;

  const MedicationEntity({
    this.id,
    this.archived,
    this.note,
    this.instructions,
    this.purpose,
    this.timeOfDay,
    this.storageLocation,
    this.storageTemperature,
    this.medicationName,
    this.dose,
    this.endDate,
    this.startDate,
    this.dateUpdated,
    this.dateCreated,
    this.userUpdated,
    this.userCreated,
    this.childId,
    this.consentDocumentId,
  });

  @override
  List<Object?> get props => [
        id,
        archived,
        note,
        instructions,
        purpose,
        timeOfDay,
        storageLocation,
        storageTemperature,
        medicationName,
        dose,
        endDate,
        startDate,
        dateUpdated,
        dateCreated,
        userUpdated,
        userCreated,
        childId,
        consentDocumentId,
      ];
}

