import 'package:equatable/equatable.dart';

class PhysicalRequirementEntity extends Equatable {
  final String? id;
  final String? requirementName;
  final String? childId;
  final String? dateCreated;
  final String? dateUpdated;
  final String? userCreated;
  final String? userUpdated;

  const PhysicalRequirementEntity({
    this.id,
    this.requirementName,
    this.childId,
    this.dateCreated,
    this.dateUpdated,
    this.userCreated,
    this.userUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        requirementName,
        childId,
        dateCreated,
        dateUpdated,
        userCreated,
        userUpdated,
      ];
}
