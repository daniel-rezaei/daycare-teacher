import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityMoodApi {
  final Dio httpclient;
  ActivityMoodApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;

    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
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
    final response = await httpclient.post('/items/activities', data: data);
    final activityId = response.data['data']['id'] as String;
    return activityId;
  }

  /// STEP B: Create mood details (child record) linked to activity
  /// Body: activity_id, mood (UUID), description, tag, photo: [{ directus_files_id }]
  Future<Response> createMoodDetails({
    required String activityId,
    required String mood,
    String? description,
    String? tag,
    List<String>? photo,
  }) async {
    final photoPayload = (photo ?? [])
        .map((id) => <String, String>{'directus_files_id': id})
        .toList();
    final data = <String, dynamic>{
      'activity_id': activityId,
      'mood_id': mood,
      'description': description ?? '',
      'tag': tag ?? '',
      'photo': photoPayload,
    };
    try {
      final response = await httpclient.post(
        '/items/activity_mood',
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get mood options from GET /items/mood
  /// Response: { "data": [ { "description": null, "name": "Unwell", "id": "..." }, ... ] }
  Future<List<Map<String, String>>> getMoodOptions() async {
    try {
      final response = await httpclient.get('/items/mood');
      final root = response.data as Map<String, dynamic>;
      final dataList = root['data'] as List<dynamic>;
      final moods = dataList.map((e) {
        final item = e as Map<String, dynamic>;
        return {
          'id': item['id']?.toString() ?? '',
          'name': item['name']?.toString() ?? '',
        };
      }).toList();
      return moods;
    } catch (e) {
      return [];
    }
  }

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
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
      return hasHistory;
    } catch (e) {
      return false;
    }
  }
}
