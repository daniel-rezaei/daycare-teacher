import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';

@immutable
class ContactModel extends ContactEntity {
  const ContactModel({
    super.id,
    super.note,
    super.role,
    super.phone,
    super.firstName,
    super.lastName,
    super.streetAddress,
    super.provinceState,
    super.postalCode,
    super.country,
    super.email,
    super.dateCreated,
    super.dateUpdated,
    super.photo,
    super.userUpdated,
    super.userCreated,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String?,
      note: json['Note'],
      role: json['Role'] as String?,
      phone: json['Phone'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      streetAddress: json['street_address'] as String?,
      provinceState: json['province_state'] as String?,
      postalCode: json['postal_code'],
      country: json['country'] as String?,
      email: json['email'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
      photo: json['photo'],
      userUpdated: json['user_updated'] as String?,
      userCreated: json['user_created'] as String?,
    );
  }
}
