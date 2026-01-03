import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityBathroomApi {
  final Dio httpclient;
  ActivityBathroomApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[BATHROOM_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;

    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[BATHROOM_API] Found activity type ID for $type: $id');
        return id;
      }
    }

    throw Exception('[BATHROOM_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating bathroom details
  /// Uses UUID-based M2M pivot tables (no integer ID conversion needed)
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    debugPrint(
      '[BATHROOM_API] ========== STEP A: Creating Activity (Parent) ==========',
    );

    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('bathroom');

    final data = <String, dynamic>{
      'activity_type_id': activityTypeId,
      'start_at': startAtUtc,
      'visibility': 'parents',
      'status': 'published',
      'has_media': true,
      // UUID based M2M pivot (VERY IMPORTANT)
      'class_id': classId,
      'child_id': childId,
    };

    debugPrint('[BATHROOM_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[BATHROOM_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create bathroom details (child record) linked to activity
  /// Tags are now included in the API payload as per backend requirements
  Future<Response> createBathroomDetails({
    required String activityId,
    required String type,
    required String subType,
    String? description,
    List<String>? tags,
    String? photo, // file ID
  }) async {
    debugPrint(
      '[BATHROOM_API] ========== STEP B: Creating Bathroom Details (Child) ==========',
    );
    debugPrint('[BATHROOM_API] activityId: $activityId');
    debugPrint('[BATHROOM_API] type: $type');
    debugPrint('[BATHROOM_API] sub_type: $subType');
    debugPrint('[BATHROOM_API] tags: $tags');
    debugPrint('[BATHROOM_API] description: $description');
    debugPrint('[BATHROOM_API] photo: $photo');

    final data = <String, dynamic>{
      'activity_id': activityId,
      'type': type,
      'sub_type': subType,
    };

    if (description != null && description.isNotEmpty) {
      data['description'] = description;
    }

    if (tags != null && tags.isNotEmpty) {
      data['tag'] = tags;
    }

    if (photo != null && photo.isNotEmpty) {
      data['photo'] = {
        'create': [
          {'directus_files_id': photo},
        ],
      };
    }

    debugPrint('[BATHROOM_API] Bathroom details request data: $data');

    debugPrint('================= DIRECTUS RAW BODY =================');
    debugPrint(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/activity_bathroom',
        data: data,
      );
      debugPrint(
        '[BATHROOM_API] Bathroom details response status: ${response.statusCode}',
      );
      debugPrint(
        '[BATHROOM_API] Bathroom details response data: ${response.data}',
      );
      return response;
    } catch (e, stackTrace) {
      debugPrint('[BATHROOM_API] Error creating bathroom details: $e');
      debugPrint('[BATHROOM_API] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get bathroom type options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getBathroomTypes() async {
    debugPrint(
      '[BATHROOM_API] Fetching bathroom type options from /fields/activity_bathroom/type',
    );
    try {
      final response = await httpclient.get('/fields/activity_bathroom/type');
      debugPrint(
        '[BATHROOM_API] Bathroom type response status: ${response.statusCode}',
      );
      debugPrint(
        '[BATHROOM_API] Bathroom type response data: ${response.data}',
      );

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices.map((e) => e['value'].toString()).toList();

      debugPrint('[BATHROOM_API] Parsed bathroom type values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[BATHROOM_API] Error fetching bathroom types: $e');
      debugPrint('[BATHROOM_API] StackTrace: $stackTrace');
      return [];
    }
  }

  /// Get sub-type options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getSubTypes() async {
    debugPrint(
      '[BATHROOM_API] Fetching sub-type options from /fields/activity_bathroom/sub_type',
    );
    try {
      final response = await httpclient.get(
        '/fields/activity_bathroom/sub_type',
      );
      debugPrint(
        '[BATHROOM_API] Sub-type response status: ${response.statusCode}',
      );
      debugPrint('[BATHROOM_API] Sub-type response data: ${response.data}');

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices.map((e) => e['value'].toString()).toList();

      debugPrint('[BATHROOM_API] Parsed sub-type values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[BATHROOM_API] Error fetching sub-types: $e');
      debugPrint('[BATHROOM_API] StackTrace: $stackTrace');
      return [];
    }
  }

  // Tags are LOCAL-ONLY - removed getTags() method
  // Tags are display-only and local-editable, no API calls needed
}
