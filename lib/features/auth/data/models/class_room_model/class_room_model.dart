import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';

@immutable
class ClassRoomModel extends ClassRoomEntity {
  const ClassRoomModel({
    super.id,
    super.roomName,
    super.maxCapacity,
    super.note,
    super.currentClass,
  });

  factory ClassRoomModel.fromJson(Map<String, dynamic> json) {
    return ClassRoomModel(
      id: json['id'] as String?,
      roomName: json['room_name'] as String?,
      maxCapacity: json['Max_Capacity'] as String?,
      note: json['Note'],
      currentClass: json['current_class'] as List<dynamic>?,
    );
  }
}
