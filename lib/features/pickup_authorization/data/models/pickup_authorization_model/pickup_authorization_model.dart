import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';

@immutable
class PickupAuthorizationModel extends PickupAuthorizationEntity {
  const PickupAuthorizationModel({
    super.id,
    super.childId,
    super.authorizedContactId,
    super.relationToChild,
    super.dateCreated,
    super.dateUpdated,
    super.userCreated,
    super.userUpdated,
  });

  factory PickupAuthorizationModel.fromJson(Map<String, dynamic> json) {
    return PickupAuthorizationModel(
      id: json['id'] as String?,
      childId: json['child_id'] as String?,
      authorizedContactId: json['authorized_contact_id'] as String?,
      relationToChild: json['relation_to_child'] as String?,
      dateCreated: json['date_created'] as String?,
      dateUpdated: json['date_updated'] as String?,
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
    );
  }
}

