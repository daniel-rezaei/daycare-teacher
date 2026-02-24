import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  final String? id;
  final String? note;
  final String? role;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? streetAddress;
  final String? provinceState;
  final String? postalCode;
  final String? country;
  final String? email;
  final String? dateCreated;
  final String? dateUpdated;
  final String? photo;
  final String? userUpdated;
  final String? userCreated;

  const ContactEntity({
    this.id,
    this.note,
    this.role,
    this.phone,
    this.firstName,
    this.lastName,
    this.streetAddress,
    this.provinceState,
    this.postalCode,
    this.country,
    this.email,
    this.dateCreated,
    this.dateUpdated,
    this.photo,
    this.userUpdated,
    this.userCreated,
  });

  @override
  List<Object?> get props => [
        id,
        note,
        role,
        phone,
        firstName,
        lastName,
        streetAddress,
        provinceState,
        postalCode,
        country,
        email,
        dateCreated,
        dateUpdated,
        photo,
        userUpdated,
        userCreated,
      ];
}
