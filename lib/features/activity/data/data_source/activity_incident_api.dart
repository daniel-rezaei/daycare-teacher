import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityIncidentApi {
  final Dio httpclient;
  ActivityIncidentApi(this.httpclient);

  /// Get field options from Child_Incident_Report table
  /// Returns list of choice texts from data.meta.options.choices[].text (for display)
  Future<List<String>> getFieldOptions(String fieldName) async {
    debugPrint(
      '[INCIDENT_API] Fetching $fieldName options from /fields/Child_Incident_Report/$fieldName',
    );
    try {
      final response = await httpclient.get(
        '/fields/Child_Incident_Report/$fieldName',
      );
      debugPrint(
        '[INCIDENT_API] $fieldName response status: ${response.statusCode}',
      );
      debugPrint('[INCIDENT_API] $fieldName response data: ${response.data}');

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      // Use 'text' for display (e.g., "Bite" instead of "bite")
      final texts = choices.map((e) => e['text'].toString()).toList();

      debugPrint('[INCIDENT_API] Parsed $fieldName texts: $texts');
      return texts;
    } catch (e, stackTrace) {
      debugPrint('[INCIDENT_API] Error fetching $fieldName: $e');
      debugPrint('[INCIDENT_API] StackTrace: $stackTrace');
      return [];
    }
  }

  /// Get nature of injury options
  Future<List<String>> getNatureOfInjuryOptions() async {
    return getFieldOptions('nature_of_injury');
  }

  /// Get location options
  Future<List<String>> getLocationOptions() async {
    return getFieldOptions('location');
  }

  /// Get notify by options
  Future<List<String>> getNotifyByOptions() async {
    return getFieldOptions('notify_by');
  }

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[INCIDENT_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;

    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[INCIDENT_API] Found activity type ID for $type: $id');
        return id;
      }
    }

    throw Exception('[INCIDENT_API] Activity type not found for: $type');
  }

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
    debugPrint(
      '[INCIDENT_API] ========== Checking history for classId: $classId ==========',
    );
    try {
      final activityTypeId = await _getActivityTypeId('incident');
      debugPrint('[INCIDENT_API] Activity type ID: $activityTypeId');

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

      debugPrint(
        '[INCIDENT_API] ========== History check result: $hasHistory (found ${data.length} items) ==========',
      );
      return hasHistory;
    } catch (e, stackTrace) {
      debugPrint('[INCIDENT_API] Error checking history: $e');
      debugPrint('[INCIDENT_API] StackTrace: $stackTrace');
      return false; // On error, assume no history to show children list
    }
  }
}
