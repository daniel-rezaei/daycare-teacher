import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_category_entity.dart';

@immutable
class LearningCategoryModel extends LearningCategoryEntity {
  const LearningCategoryModel({
    required super.id,
    required super.name,
    super.description,
  });

  factory LearningCategoryModel.fromLearningCategoryItem(
    LearningCategoryItem item,
  ) {
    return LearningCategoryModel(
      id: item.id,
      name: item.name,
      description: item.description,
    );
  }
}
