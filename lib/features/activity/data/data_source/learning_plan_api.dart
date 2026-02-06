import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class LearningPlanApi {
  final Dio httpclient;
  LearningPlanApi(this.httpclient);

  /// Create a single Learning Plan record (no parent activity table).
  /// POST {{base_url}}/items/Learning_Plan
  Future<Response> createLearningPlan({
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
    debugPrint('[LEARNING_PLAN_API] ========== Creating Learning Plan ==========');
    debugPrint('[LEARNING_PLAN_API] title: $title');
    debugPrint('[LEARNING_PLAN_API] category: $category');
    debugPrint('[LEARNING_PLAN_API] start_date: $startDate, end_date: $endDate');

    final data = <String, dynamic>{
      'title': title,
      'category': category,
      'start_date': startDate,
      'end_date': endDate,
      'age_group_id': ageGroupId,
      'class_id': classId,
      'video_link': videoLink ?? '',
      'tags': tags ?? [],
      'description': description ?? '',
    };

    debugPrint('[LEARNING_PLAN_API] Request data: $data');

    final response = await httpclient.post(
      '/items/Learning_Plan',
      data: data,
    );

    debugPrint('[LEARNING_PLAN_API] Response status: ${response.statusCode}');
    debugPrint('[LEARNING_PLAN_API] Response data: ${response.data}');
    return response;
  }
}
