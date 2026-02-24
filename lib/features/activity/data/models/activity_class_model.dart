import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/domain/entity/activity_class_entity.dart';

@immutable
class ActivityClassModel extends ActivityClassEntity {
  const ActivityClassModel({
    required super.id,
    required super.roomName,
  });

  factory ActivityClassModel.fromClassItem(ClassItem item) {
    return ActivityClassModel(
      id: item.id,
      roomName: item.roomName,
    );
  }
}
