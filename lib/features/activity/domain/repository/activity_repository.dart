import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/activity/domain/entity/activity_class_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/age_group_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_category_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_plan_entity.dart';

abstract class ActivityRepository {
  /// لیست برنامه‌های یادگیری یک کلاس
  Future<DataState<List<LearningPlanEntity>>> getLearningPlans(String classId);

  /// جزئیات یک برنامه یادگیری
  Future<DataState<LearningPlanEntity?>> getLearningPlanById(String id);

  /// دسته‌بندی‌های یادگیری (برای فرم ایجاد)
  Future<DataState<List<LearningCategoryEntity>>> getLearningCategories();

  /// گروه‌های سنی
  Future<DataState<List<AgeGroupEntity>>> getAgeGroups();

  /// لیست کلاس‌ها
  Future<DataState<List<ActivityClassEntity>>> getClasses();

  /// ایجاد برنامه یادگیری جدید
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
  });

  /// آیا این کلاس حداقل یک برنامه یادگیری دارد؟
  Future<DataState<bool>> hasHistory(String classId);
}
