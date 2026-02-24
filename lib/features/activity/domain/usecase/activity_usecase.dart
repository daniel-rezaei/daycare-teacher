import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/activity/domain/entity/activity_class_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/age_group_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_category_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_plan_entity.dart';
import 'package:teacher_app/features/activity/domain/repository/activity_repository.dart';

@singleton
class ActivityUsecase {
  final ActivityRepository activityRepository;

  ActivityUsecase(this.activityRepository);

  Future<DataState<List<LearningPlanEntity>>> getLearningPlans(
    String classId,
  ) async {
    return activityRepository.getLearningPlans(classId);
  }

  Future<DataState<LearningPlanEntity?>> getLearningPlanById(String id) async {
    return activityRepository.getLearningPlanById(id);
  }

  Future<DataState<List<LearningCategoryEntity>>> getLearningCategories() async {
    return activityRepository.getLearningCategories();
  }

  Future<DataState<List<AgeGroupEntity>>> getAgeGroups() async {
    return activityRepository.getAgeGroups();
  }

  Future<DataState<List<ActivityClassEntity>>> getClasses() async {
    return activityRepository.getClasses();
  }

  Future<DataState<void>> createLearningPlan({
    required String title,
    required String category,
    required String startDate,
    required String endDate,
    String? ageGroupId,
    String? classId,
    String? videoLink,
    List<String>? tags,
    String? description,
  }) async {
    return activityRepository.createLearningPlan(
      title: title,
      category: category,
      startDate: startDate,
      endDate: endDate,
      ageGroupId: ageGroupId,
      classId: classId,
      videoLink: videoLink,
      tags: tags,
      description: description,
    );
  }

  Future<DataState<bool>> hasHistory(String classId) async {
    return activityRepository.hasHistory(classId);
  }
}
