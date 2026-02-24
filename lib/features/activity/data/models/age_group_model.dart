import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/domain/entity/age_group_entity.dart';

@immutable
class AgeGroupModel extends AgeGroupEntity {
  const AgeGroupModel({
    required super.id,
    required super.name,
    super.key,
    super.minAgeMonths,
    super.maxAgeMonths,
  });

  factory AgeGroupModel.fromAgeGroupItem(AgeGroupItem item) {
    return AgeGroupModel(
      id: item.id,
      name: item.name,
      key: item.key,
      minAgeMonths: item.minAgeMonths,
      maxAgeMonths: item.maxAgeMonths,
    );
  }
}
