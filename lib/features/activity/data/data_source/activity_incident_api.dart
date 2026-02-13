import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityIncidentApi {
  final Dio httpclient;
  ActivityIncidentApi(this.httpclient);

  /// Get field options from Child_Incident_Report table
  /// Returns list of choice texts from data.meta.options.choices[].text (for display)
  Future<List<String>> getFieldOptions(String fieldName) async {
    try {
      final response = await httpclient.get(
        '/fields/Child_Incident_Report/$fieldName',
      );
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      // Use 'text' for display (e.g., "Bite" instead of "bite")
      final texts = choices.map((e) => e['text'].toString()).toList();
      return texts;
    } catch (e) {
      return [];
    }
  }

  /// Get nature of incident options
  Future<List<String>> getNatureOfIncidentOptions() async {
    return getFieldOptions('nature_of_incident');
  }

  /// Get location options
  Future<List<String>> getLocationOptions() async {
    return getFieldOptions('location');
  }

  /// Get notify by options
  Future<List<String>> getNotifyByOptions() async {
    return getFieldOptions('notify_by');
  }

  /// Get notify parent by options
  Future<List<String>> getNotifyParentByOptions() async {
    return getFieldOptions('notify_parent_by');
  }

  /// Get notify ministry by options
  Future<List<String>> getNotifyMinistryByOptions() async {
    return getFieldOptions('notify_ministry_by');
  }

  /// Get notify supervisor by options
  Future<List<String>> getNotifySupervisorByOptions() async {
    return getFieldOptions('notify_supervisor_by');
  }

  /// Get notify cas by options
  Future<List<String>> getNotifyCasByOptions() async {
    return getFieldOptions('notify_cas_by');
  }

  /// Get notify police by options
  Future<List<String>> getNotifyPoliceByOptions() async {
    return getFieldOptions('notify_police_by');
  }

  /// Convert text to value for a given field
  /// Returns the value corresponding to the text, or null if not found
  Future<String?> _getValueFromText(String fieldName, String text) async {
    try {
      final response = await httpclient.get(
        '/fields/Child_Incident_Report/$fieldName',
      );
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      for (final choice in choices) {
        if (choice['text'] == text) {
          return choice['value'].toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Convert list of texts to list of values for a given field
  /// Returns list of values corresponding to the texts
  Future<List<String>> _getValuesFromTexts(
    String fieldName,
    List<String> texts,
  ) async {
    if (texts.isEmpty) return [];

    try {
      final response = await httpclient.get(
        '/fields/Child_Incident_Report/$fieldName',
      );
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = <String>[];
      for (final text in texts) {
        for (final choice in choices) {
          if (choice['text'] == text) {
            values.add(choice['value'].toString());
            break;
          }
        }
      }
      return values;
    } catch (e) {
      return [];
    }
  }

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;

    // Try exact match first
    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        return id;
      }
    }

    // Try case-insensitive match
    for (final item in data) {
      if ((item['type'] as String).toLowerCase() == type.toLowerCase()) {
        final id = item['id'] as String;
        return id;
      }
    }

    throw Exception('[INCIDENT_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating incident details
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('incident');

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

  /// STEP B: Create incident details (child record) linked to activity
  Future<Response> createIncidentDetails({
    required String activityId,
    required String childId,
    required String dateTime, // UTC ISO8601 string
    required List<String> natureOfInjuryTexts,
    required List<String> locationTexts,
    required List<String> staffIds,
    String? staffId, // current user staff_id (Staff.id)
    String? notifyByText,
    String? notifyParentDateTime,
    String? notifyParentByText,
    String? notifyMinistryDateTime,
    String? notifyMinistryByText,
    String? notifySupervisorDateTime,
    String? notifySupervisorByText,
    String? notifyCasDateTime,
    String? notifyCasByText,
    String? notifyPoliceDateTime,
    String? notifyPoliceByText,
    String? description,
    String? photo, // file ID (string, not create[])
  }) async {
    final data = <String, dynamic>{
      'activity_id': activityId,
      'child_id': childId,
      'date_time': dateTime, // UTC ISO8601 string
    };

    // Multi-select enum fields (must be arrays)
    if (natureOfInjuryTexts.isNotEmpty) {
      final values = await _getValuesFromTexts(
        'nature_of_incident',
        natureOfInjuryTexts,
      );
      if (values.isNotEmpty) {
        data['nature_of_incident'] = values; // Array for multi-select
      }
    }

    if (locationTexts.isNotEmpty) {
      final values = await _getValuesFromTexts('location', locationTexts);
      if (values.isNotEmpty) {
        data['location'] = values; // Array for multi-select
      }
    }

    // contact_id: array format (multi-select) - using contact_id instead of staff_id
    if (staffIds.isNotEmpty) {
      data['contact_id'] = staffIds.first; // Array for multi-select
    }
    if (staffId != null && staffId.isNotEmpty) {
      data['staff_id'] = staffId;
    }

    // notify_by: array format (multi-select)
    if (notifyByText != null && notifyByText.isNotEmpty) {
      final value = await _getValueFromText('notify_by', notifyByText);
      if (value != null) {
        data['notify_by'] = [value]; // Array format
      }
    }

    // Persons Notified fields
    if (notifyParentDateTime != null && notifyParentDateTime.isNotEmpty) {
      data['notify_parent_date_time'] = notifyParentDateTime;
    }
    if (notifyParentByText != null && notifyParentByText.isNotEmpty) {
      final value = await _getValueFromText(
        'notify_parent_by',
        notifyParentByText,
      );
      if (value != null) {
        data['notify_parent_by'] = [value]; // Array format
      }
    }

    if (notifyMinistryDateTime != null && notifyMinistryDateTime.isNotEmpty) {
      data['notify_ministry_date_time'] = notifyMinistryDateTime;
    }
    if (notifyMinistryByText != null && notifyMinistryByText.isNotEmpty) {
      final value = await _getValueFromText(
        'notify_ministry_by',
        notifyMinistryByText,
      );
      if (value != null) {
        data['notify_ministry_by'] = [value]; // Array format
      }
    }

    if (notifySupervisorDateTime != null &&
        notifySupervisorDateTime.isNotEmpty) {
      data['notify_supervisor_date_time'] = notifySupervisorDateTime;
    }
    if (notifySupervisorByText != null && notifySupervisorByText.isNotEmpty) {
      final value = await _getValueFromText(
        'notify_supervisor_by',
        notifySupervisorByText,
      );
      if (value != null) {
        data['notify_supervisor_by'] = [value]; // Array format
      }
    }

    if (notifyCasDateTime != null && notifyCasDateTime.isNotEmpty) {
      data['notify_cas_date_time'] = notifyCasDateTime;
    }
    if (notifyCasByText != null && notifyCasByText.isNotEmpty) {
      final value = await _getValueFromText('notify_cas_by', notifyCasByText);
      if (value != null) {
        data['notify_cas_by'] = [value]; // Array format
      }
    }

    if (notifyPoliceDateTime != null && notifyPoliceDateTime.isNotEmpty) {
      data['notify_police_date_time'] = notifyPoliceDateTime;
    }
    if (notifyPoliceByText != null && notifyPoliceByText.isNotEmpty) {
      final value = await _getValueFromText(
        'notify_police_by',
        notifyPoliceByText,
      );
      if (value != null) {
        data['notify_police_by'] = [value]; // Array format
      }
    }

    if (description != null && description.isNotEmpty) {
      data['description'] = description; // Single value
    }

    // photo: string file ID (not create[])
    if (photo != null && photo.isNotEmpty) {
      data['photo'] = photo; // String file ID
    }
    try {
      final response = await httpclient.post(
        '/items/Child_Incident_Report',
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
    try {
      final activityTypeId = await _getActivityTypeId('incident');
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
      return hasHistory;
    } catch (e) {
      return false; // On error, assume no history to show children list
    }
  }
}
