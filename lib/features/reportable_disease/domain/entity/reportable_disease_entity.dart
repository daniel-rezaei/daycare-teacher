import 'package:equatable/equatable.dart';

class ReportableDiseaseEntity extends Equatable {
  final String? id;
  final String? diseaseName;
  final String? childId;
  final String? dateCreated;
  final String? dateUpdated;
  final String? userCreated;
  final String? userUpdated;

  const ReportableDiseaseEntity({
    this.id,
    this.diseaseName,
    this.childId,
    this.dateCreated,
    this.dateUpdated,
    this.userCreated,
    this.userUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        diseaseName,
        childId,
        dateCreated,
        dateUpdated,
        userCreated,
        userUpdated,
      ];
}

