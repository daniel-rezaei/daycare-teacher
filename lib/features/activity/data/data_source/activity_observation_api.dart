import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityObservationApi {
  final Dio httpclient;
  ActivityObservationApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[OBSERVATION_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;

    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[OBSERVATION_API] Found activity type ID for $type: $id');
        return id;
      }
    }

    throw Exception('[OBSERVATION_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating observation details
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    debugPrint(
      '[OBSERVATION_API] ========== STEP A: Creating Activity (Parent) ==========',
    );

    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('observation');

    final data = <String, dynamic>{
      'activity_type_id': activityTypeId,
      'start_at': startAtUtc,
      'visibility': 'parents',
      'status': 'published',
      'has_media': true,
      'class_id': classId,
      'child_id': childId,
    };

    debugPrint('[OBSERVATION_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[OBSERVATION_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create observation details (child record) linked to activity
  Future<Response> createObservationDetails({
    required String activityId,
    required String domainId, // assessment_domain.id
    String? skillObserved,
    String? description,
    List<String>? tags, // Development Area
    String? photo, // file ID
    bool? followUpRequired,
    bool? shareWithParent,
  }) async {
    debugPrint(
      '[OBSERVATION_API] ========== STEP B: Creating Observation Details (Child) ==========',
    );
    debugPrint('[OBSERVATION_API] activityId: $activityId');
    debugPrint('[OBSERVATION_API] domain_id: $domainId');
    debugPrint('[OBSERVATION_API] skill_observed: $skillObserved');
    debugPrint('[OBSERVATION_API] tags: $tags');
    debugPrint('[OBSERVATION_API] description: $description');
    debugPrint('[OBSERVATION_API] photo: $photo');
    debugPrint('[OBSERVATION_API] follow_up_required: $followUpRequired');
    debugPrint('[OBSERVATION_API] share_with_parent: $shareWithParent');

    final data = <String, dynamic>{
      'activity_id': activityId,
      // 'domain_id': domainId,
      // if (skillObserved != null && skillObserved.isNotEmpty)
      //   'skill_observed': skillObserved, // skillObserved is already the value from CategoryModel
      if (description != null && description.isNotEmpty)
        'description': description,
      if (tags != null && tags.isNotEmpty) 'tag': tags,
      if (photo != null && photo.isNotEmpty) 'photo': photo,
      if (followUpRequired != null) 'follow_up_required': followUpRequired,
      if (shareWithParent != null) 'share_with_parent': shareWithParent,
    };

    debugPrint('[OBSERVATION_API] Observation details request data: $data');
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/Observation_Record',
        data: data,
      );
      debugPrint(
        '[OBSERVATION_API] Observation details response status: ${response.statusCode}',
      );
      debugPrint(
        '[OBSERVATION_API] Observation details response data: ${response.data}',
      );
      return response;
    } catch (e, stackTrace) {
      debugPrint('[OBSERVATION_API] Error creating observation details: $e');
      debugPrint('[OBSERVATION_API] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get domain options (assessment_domain.id and name)
  /// Returns list of maps with 'id' and 'name' keys
Future<List<Map<String, String>>> getDomainOptions() async {
  final response = await httpclient.get('/items/assessment_domain');

  final data = response.data['data'] as List<dynamic>;

  return data.map((item) {
    return {
      'id': item['id'].toString(),
      'name': item['name']?.toString() ?? '',
    };
  }).toList();
}

  /// Get category options from Assessment_Domain.Name field
  /// Returns list of CategoryModel with value and name from choices
  Future<List<CategoryModel>> getCategoryOptions() async {
    debugPrint('[OBSERVATION_API] Fetching categories from Assessment_Domain/Name');
    
    try {
      final response = await httpclient.get(
        '/fields/Assessment_Domain/Name',
      );
      debugPrint(
        '[OBSERVATION_API] Category options response status: ${response.statusCode}',
      );
      debugPrint('[OBSERVATION_API] Category options response data: ${response.data}');

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      // Extract value and text (name) from choices
      final categories = choices.map((choice) {
        return CategoryModel(
          value: choice['value']?.toString() ?? '',
          name: choice['text']?.toString() ?? '',
        );
      }).toList();

      debugPrint('[OBSERVATION_API] Parsed category options: ${categories.map((e) => e.name).toList()}');
      return categories;
    } catch (e, stackTrace) {
      debugPrint('[OBSERVATION_API] Error fetching category options: $e');
      debugPrint('[OBSERVATION_API] StackTrace: $stackTrace');
      return [];
    }
  }


  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
    debugPrint('[OBSERVATION_API] Checking history for classId: $classId');
    try {
      final activityTypeId = await _getActivityTypeId('observation');

      final response = await httpclient.get(
        '/items/activities',
        queryParameters: {
          'filter[activity_type_id][_eq]': activityTypeId,
          'filter[class_id][_eq]': classId,
          'limit': 1,
        },
      );

      final data = response.data['data'] as List<dynamic>;
      final hasHistory = data.isNotEmpty;

      debugPrint(
        '[OBSERVATION_API] History check result: $hasHistory (found ${data.length} items)',
      );
      return hasHistory;
    } catch (e, stackTrace) {
      debugPrint('[OBSERVATION_API] Error checking history: $e');
      debugPrint('[OBSERVATION_API] StackTrace: $stackTrace');
      return false;
    }
  }
}
class CategoryModel {
  final String value;
  final String name;

  CategoryModel({required this.value, required this.name});
}
