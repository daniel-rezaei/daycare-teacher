import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/class_transfer_request/domain/entity/class_transfer_request_entity.dart';

@immutable
class ClassTransferRequestModel extends ClassTransferRequestEntity {
  const ClassTransferRequestModel({
    super.id,
    super.studentId,
    super.fromClassId,
    super.toClassId,
    super.status,
    super.dateCreated,
    super.dateUpdated,
  });

  factory ClassTransferRequestModel.fromJson(Map<String, dynamic> json) {
    return ClassTransferRequestModel(
      id: json['id'] as String?,
      studentId: json['student_id'] as String?,
      fromClassId: json['from_class_id'] as String?,
      toClassId: json['to_class_id'] as String?,
      status: json['status'] as String?,
      dateCreated: json['date_created'] as String?, // May not be available in API response
      dateUpdated: json['date_updated'] as String?, // May not be available in API response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (fromClassId != null) 'from_class_id': fromClassId,
      if (toClassId != null) 'to_class_id': toClassId,
      if (status != null) 'status': status,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
    };
  }
}

