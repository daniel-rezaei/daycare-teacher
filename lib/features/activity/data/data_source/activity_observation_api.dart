import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityObservationApi {
  final Dio httpclient;
  ActivityObservationApi(this.httpclient);

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

    throw Exception('[OBSERVATION_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating observation details
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
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
    final response = await httpclient.post('/items/activities', data: data);
    final activityId = response.data['data']['id'] as String;
    return activityId;
  }

  /// STEP B: Create observation details (child record) linked to activity
  /// Payload: domain_id, skill_observed (array), description, follow_up, share_with_parent, activity_id
  Future<Response> createObservationDetails({
    required String activityId,
    required String domainId,
    List<String>? skillObserved,
    String? description,
    String? photo,
    bool? followUpRequired,
    bool? shareWithParent,
    String? staffId,
  }) async {
    final data = <String, dynamic>{
      'category_id': domainId,
      'activity_id': activityId,
      'description': description ?? '',
      'follow_up': followUpRequired ?? false,
      'share_with_parent': shareWithParent ?? true,
      if (skillObserved != null && skillObserved.isNotEmpty)
        'skill_observed': skillObserved,
      if (photo != null && photo.isNotEmpty) 'photo': photo,
      if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
    };
    try {
      final response = await httpclient.post(
        '/items/Observation_Record',
        data: data,
      );
      return response;
    } catch (e) {
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

  /// Get category options from observation_category collection.
  /// Returns list of CategoryModel with value=id and name for display.
  /// The selected category's id is sent as domain_id to Observation_Record.
  Future<List<CategoryModel>> getCategoryOptions() async {
    try {
      final response = await httpclient.get('/items/observation_category');

      final data = response.data['data'] as List<dynamic>;

      final categories = data.map((item) {
        return CategoryModel(
          value: item['id']?.toString() ?? '',
          name: item['name']?.toString() ?? '',
        );
      }).toList();
      return categories;
    } catch (e) {
      return [];
    }
  }

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
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
      return hasHistory;
    } catch (e) {
      return false;
    }
  }
}

class CategoryModel {
  final String value;
  final String name;

  CategoryModel({required this.value, required this.name});
}
