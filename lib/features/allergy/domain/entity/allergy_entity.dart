import 'package:equatable/equatable.dart';

class AllergyEntity extends Equatable {
  final String? id;
  final String? allergenName;
  final String? childId;
  final String? dateCreated;
  final String? dateUpdated;
  final String? userCreated;
  final String? userUpdated;

  const AllergyEntity({
    this.id,
    this.allergenName,
    this.childId,
    this.dateCreated,
    this.dateUpdated,
    this.userCreated,
    this.userUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        allergenName,
        childId,
        dateCreated,
        dateUpdated,
        userCreated,
        userUpdated,
      ];
}

