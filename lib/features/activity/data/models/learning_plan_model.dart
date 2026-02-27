import 'package:flutter/foundation.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_plan_entity.dart';

@immutable
class LearningPlanModel extends LearningPlanEntity {
  const LearningPlanModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.endDate,
    super.categoryId,
    super.categoryName = '',
    super.ageGroupId,
    super.ageBandName = '',
    super.classId,
    super.roomName = '',
    super.videoLink,
    super.tags = const [],
    super.description,
    super.fileId,
    super.fileName,
    super.fileUrl,
  });

  factory LearningPlanModel.fromLearningPlanItem(LearningPlanItem item) {
    return LearningPlanModel(
      id: item.id,
      title: item.title,
      startDate: item.startDate,
      endDate: item.endDate,
      categoryId: item.categoryId,
      categoryName: item.categoryName,
      ageGroupId: item.ageGroupId,
      ageBandName: item.ageBandName,
      classId: item.classId,
      roomName: item.roomName,
      videoLink: item.videoLink,
      tags: List<String>.from(item.tags),
      description: item.description,
      fileId: item.fileId,
      fileName: item.fileName,
      fileUrl: item.fileUrl,
    );
  }
}
