import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityMoodApi {
  final Dio httpclient;
  ActivityMoodApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[MOOD_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;
    
    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[MOOD_API] Found activity type ID for $type: $id');
        return id;
      }
    }
    
    throw Exception('[MOOD_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating mood details
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    debugPrint('[MOOD_API] ========== STEP A: Creating Activity (Parent) ==========');

    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('mood');

    final data = <String, dynamic>{
      'activity_type_id': activityTypeId,
      'start_at': startAtUtc,
      'visibility': 'parents',
      'status': 'published',
      'has_media': true,
      'class_id': classId,
      'child_id': childId,
    };

    debugPrint('[MOOD_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[MOOD_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create mood details (child record) linked to activity
  /// Body: description, tag (string), mood (mood id/name), activity_id, photo (array)
  Future<Response> createMoodDetails({
    required String activityId,
    required String mood,
    String? description,
    String? tag,
    List<String>? photo,
  }) async {
    debugPrint('[MOOD_API] ========== STEP B: Creating Mood Details (Child) ==========');
    debugPrint('[MOOD_API] activityId: $activityId');
    debugPrint('[MOOD_API] mood: $mood');
    debugPrint('[MOOD_API] tag: $tag');
    debugPrint('[MOOD_API] description: $description');
    debugPrint('[MOOD_API] photo: $photo');

    final data = <String, dynamic>{
      'activity_id': activityId,
      'mood': mood,
      'description': description ?? '',
      'tag': tag ?? '',
      'photo': photo ?? [],
    };

    debugPrint('[MOOD_API] Mood details request data: $data');
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/activity_mood',
        data: data,
      );
      debugPrint('[MOOD_API] Mood details response status: ${response.statusCode}');
      debugPrint('[MOOD_API] Mood details response data: ${response.data}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[MOOD_API] Error creating mood details: $e');
      debugPrint('[MOOD_API] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get mood options from GET /items/mood
  /// Response: { "data": [ { "description": null, "name": "Unwell", "id": "..." }, ... ] }
  Future<List<Map<String, String>>> getMoodOptions() async {
    debugPrint('[MOOD_API] Fetching mood options from /items/mood');
    try {
      final response = await httpclient.get('/items/mood');
      debugPrint('[MOOD_API] Mood response status: ${response.statusCode}');
      debugPrint('[MOOD_API] Mood response data: ${response.data}');

      final root = response.data as Map<String, dynamic>;
      final dataList = root['data'] as List<dynamic>;

      final moods = dataList.map((e) {
        final item = e as Map<String, dynamic>;
        return {
          'id': item['id']?.toString() ?? '',
          'name': item['name']?.toString() ?? '',
        };
      }).toList();

      debugPrint('[MOOD_API] Parsed mood options: $moods');
      return moods;
    } catch (e, stackTrace) {
      debugPrint('[MOOD_API] Error fetching mood options: $e');
      debugPrint('[MOOD_API] StackTrace: $stackTrace');
      return [];
    }
  }

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
    debugPrint('[MOOD_API] Checking history for classId: $classId');
    try {
      final activityTypeId = await _getActivityTypeId('mood');
      
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
      
      debugPrint('[MOOD_API] History check result: $hasHistory (found ${data.length} items)');
      return hasHistory;
    } catch (e, stackTrace) {
      debugPrint('[MOOD_API] Error checking history: $e');
      debugPrint('[MOOD_API] StackTrace: $stackTrace');
      return false;
    }
  }
}

