import 'package:equatable/equatable.dart';

class ImmunizationEntity extends Equatable {
  final String? id;
  final String? vaccineName;
  final String? childId;
  final String? dateCreated;
  final String? dateUpdated;
  final String? userCreated;
  final String? userUpdated;

  const ImmunizationEntity({
    this.id,
    this.vaccineName,
    this.childId,
    this.dateCreated,
    this.dateUpdated,
    this.userCreated,
    this.userUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        vaccineName,
        childId,
        dateCreated,
        dateUpdated,
        userCreated,
        userUpdated,
      ];
}

