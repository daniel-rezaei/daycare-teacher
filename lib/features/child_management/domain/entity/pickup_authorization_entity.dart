import 'package:equatable/equatable.dart';

class PickupAuthorizationEntity extends Equatable {
  final String? id;
  final String? childId;
  final String? authorizedContactId;
  final String? relationToChild;
  final String? dateCreated;
  final String? dateUpdated;
  final String? userCreated;
  final String? userUpdated;

  const PickupAuthorizationEntity({
    this.id,
    this.childId,
    this.authorizedContactId,
    this.relationToChild,
    this.dateCreated,
    this.dateUpdated,
    this.userCreated,
    this.userUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        childId,
        authorizedContactId,
        relationToChild,
        dateCreated,
        dateUpdated,
        userCreated,
        userUpdated,
      ];
}
