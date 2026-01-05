import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityAccidentApi {
  final Dio httpclient;
  ActivityAccidentApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[ACCIDENT_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;

    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[ACCIDENT_API] Found activity type ID for $type: $id');
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
      debugPrint(
        '[ACCIDENT_API] Error converting text to value for $fieldName: $e',
      );
      return null;
    }
  }

  /// Get field options from Child_Accident_Report table
  /// Returns list of choice texts from data.meta.options.choices[].text (for display)
  Future<List<String>> getFieldOptions(String fieldName) async {
    debugPrint(
      '[ACCIDENT_API] Fetching $fieldName options from /fields/child_accident_report/$fieldName',
    );
    try {
      final response = await httpclient.get(
        '/fields/Child_Accident_Report/$fieldName',
      );
      debugPrint(
        '[ACCIDENT_API] $fieldName response status: ${response.statusCode}',
      );
      debugPrint('[ACCIDENT_API] $fieldName response data: ${response.data}');

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      // Use 'text' for display (e.g., "Bite" instead of "bite")
      final texts = choices.map((e) => e['text'].toString()).toList();

      debugPrint('[ACCIDENT_API] Parsed $fieldName texts: $texts');
      return texts;
    } catch (e, stackTrace) {
      debugPrint('[ACCIDENT_API] Error fetching $fieldName: $e');
      debugPrint('[ACCIDENT_API] StackTrace: $stackTrace');
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
    debugPrint(
      '[ACCIDENT_API] ========== STEP A: Creating Activity (Parent) ==========',
    );

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

    debugPrint('[ACCIDENT_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[ACCIDENT_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create accident details (child record) linked to activity
  Future<Response> createAccidentDetails({
    required String activityId,
    required String? natureOfInjuryText,
    required String? injuredBodyTypeText,
    required String? locationText,
    required String? firstAidProvidedText,
    required String? childReactionText,
    required List<String> staffIds,
    String? dateTimeNotifiedText,
    required bool medicalFollowUpRequired,
    required bool incidentReportedToAuthority,
    required bool parentNotified,
    String? notifyByText,
    String? description,
    String? photo, // file ID
  }) async {
    debugPrint(
      '[ACCIDENT_API] ========== STEP B: Creating Accident Details (Child) ==========',
    );
    debugPrint('[ACCIDENT_API] activityId: $activityId');

    final data = <String, dynamic>{'activity_id': activityId};

    // Convert text to value for each field
    if (natureOfInjuryText != null && natureOfInjuryText.isNotEmpty) {
      final value = await _getValueFromText(
        'nature_of_injury',
        natureOfInjuryText,
      );
      if (value != null) {
        data['nature_of_injury'] = [value];
      }
    }

    if (injuredBodyTypeText != null && injuredBodyTypeText.isNotEmpty) {
      final value = await _getValueFromText(
        'injured_body_type',
        injuredBodyTypeText,
      );
      if (value != null) {
        data['injured_body_type'] = value;
      }
    }

    if (locationText != null && locationText.isNotEmpty) {
      final value = await _getValueFromText('location', locationText);
      if (value != null) {
        data['location'] = value;
      }
    }

    if (firstAidProvidedText != null && firstAidProvidedText.isNotEmpty) {
      final value = await _getValueFromText(
        'first_aid_provided',
        firstAidProvidedText,
      );
      if (value != null) {
        data['first_aid_provided'] = value;
      }
    }

    if (childReactionText != null && childReactionText.isNotEmpty) {
      final value = await _getValueFromText(
        'child_reaction',
        childReactionText,
      );
      if (value != null) {
        data['child_reaction'] = value;
      }
    }

    // Staff IDs (multi-select)
    if (staffIds.isNotEmpty) {
      data['staff_id'] = staffIds;
    }

    if (dateTimeNotifiedText != null && dateTimeNotifiedText.isNotEmpty) {
      final value = await _getValueFromText(
        'date_time_notified',
        dateTimeNotifiedText,
      );
      if (value != null) {
        data['date_time_notified'] = value;
      }
    }

    data['medical_follow_up_required'] = medicalFollowUpRequired;
    data['incident_reported_to_authority'] = incidentReportedToAuthority;
    data['parent_notified'] = parentNotified;

    if (notifyByText != null && notifyByText.isNotEmpty) {
      final value = await _getValueFromText('notify_by', notifyByText);
      if (value != null) {
        data['notify_by'] = value;
      }
    }

    if (description != null && description.isNotEmpty) {
      data['description'] = description;
    }

    if (photo != null && photo.isNotEmpty) {
      data['photo'] = {
        'create': [
          {'directus_files_id': photo},
        ],
      };
    }

    debugPrint('[ACCIDENT_API] Accident details request data: $data');

    debugPrint('================= DIRECTUS RAW BODY =================');
    debugPrint(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/Child_Accident_Report',
        data: data,
      );
      debugPrint(
        '[ACCIDENT_API] Accident details response status: ${response.statusCode}',
      );
      debugPrint(
        '[ACCIDENT_API] Accident details response data: ${response.data}',
      );
      return response;
    } catch (e, stackTrace) {
      debugPrint('[ACCIDENT_API] Error creating accident details: $e');
      debugPrint('[ACCIDENT_API] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
