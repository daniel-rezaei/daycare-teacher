import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityPlayApi {
  final Dio httpclient;
  ActivityPlayApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[PLAY_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;
    
    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[PLAY_API] Found activity type ID for $type: $id');
        return id;
      }
    }
    
    throw Exception('[PLAY_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating play details
  /// Uses UUID-based M2M pivot tables (no integer ID conversion needed)
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    debugPrint('[PLAY_API] ========== STEP A: Creating Activity (Parent) ==========');

    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('play');

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

    debugPrint('[PLAY_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[PLAY_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create play details (child record) linked to activity
  /// Tags are now included in the API payload as per backend requirements
  Future<Response> createPlayDetails({
    required String activityId,
    required String type,
    String? description,
    List<String>? tags,
    String? photo, // file ID
    String? startAt,
    String? endAt,
  }) async {
    debugPrint('[PLAY_API] ========== STEP B: Creating Play Details (Child) ==========');
    debugPrint('[PLAY_API] activityId: $activityId');
    debugPrint('[PLAY_API] type: $type');
    debugPrint('[PLAY_API] tags: $tags');
    debugPrint('[PLAY_API] description: $description');
    debugPrint('[PLAY_API] photo: $photo');
    debugPrint('[PLAY_API] start_at: $startAt');
    debugPrint('[PLAY_API] end_at: $endAt');

    final data = <String, dynamic>{
      'activity_id': activityId,
      'type': type,
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
          {'directus_files_id': photo}
        ]
      };
    }

    if (startAt != null && startAt.isNotEmpty) {
      data['start_at'] = startAt;
    }

    if (endAt != null && endAt.isNotEmpty) {
      data['end_at'] = endAt;
    }

    debugPrint('[PLAY_API] Play details request data: $data');

    debugPrint('================= DIRECTUS RAW BODY =================');
    debugPrint(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/activity_play',
        data: data,
      );
      debugPrint('[PLAY_API] Play details response status: ${response.statusCode}');
      debugPrint('[PLAY_API] Play details response data: ${response.data}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[PLAY_API] Error creating play details: $e');
      debugPrint('[PLAY_API] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get play type options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getPlayTypes() async {
    debugPrint('[PLAY_API] Fetching play type options from /fields/activity_play/type');
    try {
      final response = await httpclient.get('/fields/activity_play/type');
      debugPrint('[PLAY_API] Play type response status: ${response.statusCode}');
      debugPrint('[PLAY_API] Play type response data: ${response.data}');
      
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices
          .map((e) => e['value'].toString())
          .toList();

      debugPrint('[PLAY_API] Parsed play type values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[PLAY_API] Error fetching play types: $e');
      debugPrint('[PLAY_API] StackTrace: $stackTrace');
      return [];
    }
  }

  // Tags are LOCAL-ONLY - removed getTags() method
  // Tags are display-only and local-editable, no API calls needed

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
    debugPrint('[PLAY_API] ========== Checking history for classId: $classId ==========');
    try {
      final activityTypeId = await _getActivityTypeId('play');
      debugPrint('[PLAY_API] Activity type ID: $activityTypeId');
      
      final response = await httpclient.get(
        '/items/activities',
        queryParameters: {
          'filter[activity_type_id][_eq]': activityTypeId,
          'filter[class_id][_eq]': classId,
          'limit': 1, // Only need to check if any exists
        },
      );
      
      final data = response.data['data'] as List<dynamic>;
      final hasHistory = data.isNotEmpty;
      
      debugPrint('[PLAY_API] ========== History check result: $hasHistory (found ${data.length} items) ==========');
      return hasHistory;
    } catch (e, stackTrace) {
      debugPrint('[PLAY_API] Error checking history: $e');
      debugPrint('[PLAY_API] StackTrace: $stackTrace');
      return false; // On error, assume no history to show children list
    }
  }
}

