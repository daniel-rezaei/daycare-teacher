import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// GET {{base_url}}/items/learning_category response item
class LearningCategoryItem {
  final String id;
  final String name;
  final String? description;
  LearningCategoryItem({
    required this.id,
    required this.name,
    this.description,
  });
}

/// GET {{base_url}}/items/age_group response item
class AgeGroupItem {
  final String id;
  final String name;
  final String? key;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  AgeGroupItem({
    required this.id,
    required this.name,
    this.key,
    this.minAgeMonths,
    this.maxAgeMonths,
  });
}

/// GET {{base_url}}/items/Class response item
class ClassItem {
  final String id;
  final String roomName;
  ClassItem({required this.id, required this.roomName});
}

@singleton
class LearningPlanApi {
  final Dio httpclient;
  LearningPlanApi(this.httpclient);

  /// GET {{base_url}}/items/learning_category
  Future<List<LearningCategoryItem>> getLearningCategories() async {
    final response = await httpclient.get('/items/learning_category');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return LearningCategoryItem(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        description: m['description'] as String?,
      );
    }).toList();
  }

  /// GET {{base_url}}/items/age_group
  Future<List<AgeGroupItem>> getAgeGroups() async {
    final response = await httpclient.get('/items/age_group');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return AgeGroupItem(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        key: m['key'] as String?,
        minAgeMonths: m['min_age_months'] as int?,
        maxAgeMonths: m['max_age_months'] as int?,
      );
    }).toList();
  }

  /// GET {{base_url}}/items/Class
  Future<List<ClassItem>> getClasses() async {
    final response = await httpclient.get('/items/Class');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return ClassItem(
        id: m['id'] as String,
        roomName: m['room_name'] as String? ?? '',
      );
    }).toList();
  }

  /// Create a single Learning Plan record (no parent activity table).
  /// POST {{base_url}}/items/Learning_Plan
  /// [category] is the learning_category id (UUID).
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
