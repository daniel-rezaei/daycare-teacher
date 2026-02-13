import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityAccidentApi {
  final Dio httpclient;
  ActivityAccidentApi(this.httpclient);

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

    throw Exception('[ACCIDENT_API] Activity type not found for: $type');
  }

  /// Convert text to value for a given field
  /// Returns the value corresponding to the text, or null if not found
  Future<String?> _getValueFromText(String fieldName, String text) async {
    try {
      final response = await httpclient.get(
        '/fields/Child_Accident_Report/$fieldName',
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
        '/fields/Child_Accident_Report/$fieldName',
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

  /// Get field options from Child_Accident_Report table
  /// Returns list of choice texts from data.meta.options.choices[].text (for display)
  Future<List<String>> getFieldOptions(String fieldName) async {
    try {
      final response = await httpclient.get(
        '/fields/Child_Accident_Report/$fieldName',
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

  /// Get nature of injury options
  Future<List<String>> getNatureOfInjuryOptions() async {
    return getFieldOptions('nature_of_injury');
  }

  /// Get injured body part options
  Future<List<String>> getInjuredBodyPartOptions() async {
    return getFieldOptions('injured_body_type');
  }

  /// Get location options
  Future<List<String>> getLocationOptions() async {
    return getFieldOptions('location');
  }

  /// Get first aid provided options
  Future<List<String>> getFirstAidProvidedOptions() async {
    return getFieldOptions('first_aid_provided');
  }

  /// Get child reaction options
  Future<List<String>> getChildReactionOptions() async {
    return getFieldOptions('child_reaction');
  }

  /// Get notify by options
  Future<List<String>> getNotifyByOptions() async {
    return getFieldOptions('notify_by');
  }

  /// Get date notified options
  Future<List<String>> getDateNotifiedOptions() async {
    return getFieldOptions('date_time_notified');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating accident details
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('accident');

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

  /// STEP B: Create accident details (child record) linked to activity
  Future<Response> createAccidentDetails({
    required String activityId,
    required String childId,
    required String dateTime, // UTC ISO8601 string
    required List<String> natureOfInjuryTexts,
    required List<String> injuredBodyTypeTexts,
    required List<String> locationTexts,
    required List<String> firstAidProvidedTexts,
    required List<String> childReactionTexts,
    required List<String> staffIds,
    String? dateTimeNotifiedText, // Can be enum text or ISO8601 datetime string
    required bool medicalFollowUpRequired,
    required bool incidentReportedToAuthority,
    required bool parentNotified,
    String? notifyByText,
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
        'nature_of_injury',
        natureOfInjuryTexts,
      );
      if (values.isNotEmpty) {
        data['nature_of_injury'] = values; // Array for multi-select
      }
    }

    if (injuredBodyTypeTexts.isNotEmpty) {
      final values = await _getValuesFromTexts(
        'injured_body_type',
        injuredBodyTypeTexts,
      );
      if (values.isNotEmpty) {
        data['injured_body_type'] = values; // Array for multi-select
      }
    }

    if (locationTexts.isNotEmpty) {
      final values = await _getValuesFromTexts('location', locationTexts);
      if (values.isNotEmpty) {
        data['location'] = values; // Array for multi-select
      }
    }

    if (firstAidProvidedTexts.isNotEmpty) {
      final values = await _getValuesFromTexts(
        'first_aid_provided',
        firstAidProvidedTexts,
      );
      if (values.isNotEmpty) {
        data['first_aid_provided'] = values; // Array for multi-select
      }
    }

    if (childReactionTexts.isNotEmpty) {
      final values = await _getValuesFromTexts(
        'child_reaction',
        childReactionTexts,
      );
      if (values.isNotEmpty) {
        data['child_reaction'] = values; // Array for multi-select
      }
    }

    // contact_id: array format (multi-select) - using contact_id instead of staff_id
    if (staffIds.isNotEmpty) {
      data['contact_id'] = staffIds.first; // Array for multi-select
    }

    // date_time_notified: can be enum text (convert to value) or ISO8601 datetime string (use directly)
    if (dateTimeNotifiedText != null && dateTimeNotifiedText.isNotEmpty) {
      // Check if it's an ISO8601 datetime string (contains 'T' or ':' and digits)
      if (dateTimeNotifiedText.contains('T') ||
          (dateTimeNotifiedText.contains(':') &&
              RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(dateTimeNotifiedText))) {
        // It's a datetime string, use directly
        data['date_time_notified'] = dateTimeNotifiedText;
      } else {
        // It's an enum text, convert to value
        final value = await _getValueFromText(
          'date_time_notified',
          dateTimeNotifiedText,
        );
        if (value != null) {
          data['date_time_notified'] = value;
        }
      }
    }

    data['medical_follow_up_required'] = medicalFollowUpRequired;
    data['incident_reported_to_authority'] = incidentReportedToAuthority;
    data['parent_notified'] = parentNotified;

    // notify_by: array format (multi-select)
    if (notifyByText != null && notifyByText.isNotEmpty) {
      final value = await _getValueFromText('notify_by', notifyByText);
      if (value != null) {
        data['notify_by'] = [value]; // Array format
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
        '/items/Child_Accident_Report',
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
      final activityTypeId = await _getActivityTypeId('accident');

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
