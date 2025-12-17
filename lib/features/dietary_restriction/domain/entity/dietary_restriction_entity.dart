import 'package:equatable/equatable.dart';

class DietaryRestrictionEntity extends Equatable {
  final String? id;
  final String? restrictionName;
  final String? childId;
  final String? dateCreated;
  final String? dateUpdated;
  final String? userCreated;
  final String? userUpdated;

  const DietaryRestrictionEntity({
    this.id,
    this.restrictionName,
    this.childId,
    this.dateCreated,
    this.dateUpdated,
    this.userCreated,
    this.userUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        restrictionName,
        childId,
        dateCreated,
        dateUpdated,
        userCreated,
        userUpdated,
      ];
}

