import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart';
import 'package:teacher_app/features/activity/data/models/activity_class_model.dart';
import 'package:teacher_app/features/activity/data/models/age_group_model.dart';
import 'package:teacher_app/features/activity/data/models/learning_category_model.dart';
import 'package:teacher_app/features/activity/data/models/learning_plan_model.dart';
import 'package:teacher_app/features/activity/domain/entity/activity_class_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/age_group_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_category_entity.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_plan_entity.dart';
import 'package:teacher_app/features/activity/domain/repository/activity_repository.dart';

@Singleton(as: ActivityRepository, env: [Env.prod])
class ActivityRepositoryImpl extends ActivityRepository {
  final LearningPlanApi learningPlanApi;

  ActivityRepositoryImpl(this.learningPlanApi);

  @override
  Future<DataState<List<LearningPlanEntity>>> getLearningPlans(
    String classId,
  ) async {
    try {
      final list = await learningPlanApi.getLearningPlans(classId);
      final entities = list
          .map((e) => LearningPlanModel.fromLearningPlanItem(e))
          .toList();
      return DataSuccess(entities);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<LearningPlanEntity?>> getLearningPlanById(String id) async {
    try {
      final item = await learningPlanApi.getLearningPlanById(id);
      if (item == null) return DataSuccess(null);
      return DataSuccess(LearningPlanModel.fromLearningPlanItem(item));
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<LearningCategoryEntity>>> getLearningCategories() async {
    try {
      final list = await learningPlanApi.getLearningCategories();
      final entities = list
          .map((e) => LearningCategoryModel.fromLearningCategoryItem(e))
          .toList();
      return DataSuccess(entities);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<AgeGroupEntity>>> getAgeGroups() async {
    try {
      final list = await learningPlanApi.getAgeGroups();
      final entities =
          list.map((e) => AgeGroupModel.fromAgeGroupItem(e)).toList();
      return DataSuccess(entities);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<ActivityClassEntity>>> getClasses() async {
    try {
      final list = await learningPlanApi.getClasses();
      final entities = list.map((e) => ActivityClassModel.fromClassItem(e)).toList();
      return DataSuccess(entities);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
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
    try {
      await learningPlanApi.createLearningPlan(
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
      return DataSuccess(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<bool>> hasHistory(String classId) async {
    try {
      final result = await learningPlanApi.hasHistory(classId);
      return DataSuccess(result);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    if (e.response == null) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return DataFailed<T>(
          'It seems your internet connection is active, but the server response is taking too long.',
        );
      } else {
        return DataFailed<T>('Please check your internet connection.');
      }
    } else if (e.response!.statusCode == 403) {
      return DataFailed<T>('Access to this section is restricted for you.');
    } else if (e.response!.statusCode != null &&
        e.response!.statusCode! >= 500) {
      return DataFailed<T>(
        'The server is currently under maintenance. Please be patient.',
      );
    } else {
      return DataFailed<T>('An unknown error occurred.');
    }
  }
}
