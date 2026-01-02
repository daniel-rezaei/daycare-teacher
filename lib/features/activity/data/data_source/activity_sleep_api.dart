import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivitySleepApi {
  final Dio httpclient;
  ActivitySleepApi(this.httpclient);

  // Sleep activity type UUID from backend
  static const String sleepActivityTypeId =
      '31b2a8b9-7485-4b2d-9f39-353d5b34c4de';

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating sleep details
  /// Uses UUID-based M2M pivot tables (no integer ID conversion needed)
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    debugPrint(
      '[SLEEP_API] ========== STEP A: Creating Activity (Parent) ==========',
    );

    final data = <String, dynamic>{
      'activity_type_id': sleepActivityTypeId,
      'start_at': startAtUtc,
      'visibility': 'parents',
      'status': 'published',
      'has_media': true,
      // UUID based M2M pivot (VERY IMPORTANT)
      'class_id': classId,
      'child_id': childId,
    };

    debugPrint('[SLEEP_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[SLEEP_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create sleep details (child record) linked to activity
  /// Tags are now included in the API payload as per backend requirements
  Future<Response> createSleepDetails({
    required String activityId,
    required String type,
    String? description,
    List<String>? tags,
    String? photo, // file ID
    String? startAt,
    String? endAt,
  }) async {
    debugPrint(
      '[SLEEP_API] ========== STEP B: Creating Sleep Details (Child) ==========',
    );
    debugPrint('[SLEEP_API] activityId: $activityId');
    debugPrint('[SLEEP_API] type: $type');
    debugPrint('[SLEEP_API] tags: $tags');
    debugPrint('[SLEEP_API] description: $description');
    debugPrint('[SLEEP_API] photo: $photo');
    debugPrint('[SLEEP_API] start_at: $startAt');
    debugPrint('[SLEEP_API] end_at: $endAt');

    final data = <String, dynamic>{
      'activity_id': activityId,
      'sleep_monitoring': type,
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

    if (startAt != null && startAt.isNotEmpty) {
      data['start_at'] = startAt;
    }

    if (endAt != null && endAt.isNotEmpty) {
      data['end_at'] = endAt;
    }

    debugPrint('[SLEEP_API] Sleep details request data: $data');

    debugPrint('================= DIRECTUS RAW BODY =================');
    debugPrint(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/activity_sleep',
        data: data,
      );
      debugPrint(
        '[SLEEP_API] Sleep details response status: ${response.statusCode}',
      );
      debugPrint('[SLEEP_API] Sleep details response data: ${response.data}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[SLEEP_API] Error creating sleep details: $e');
      debugPrint('[SLEEP_API] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get sleep type options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getSleepTypes() async {
    debugPrint(
      '[SLEEP_API] Fetching sleep type options from /fields/activity_sleep/sleep_monitoring',
    );
    try {
      final response = await httpclient.get(
        '/fields/activity_sleep/sleep_monitoring',
      );
      debugPrint(
        '[SLEEP_API] Sleep type response status: ${response.statusCode}',
      );
      debugPrint('[SLEEP_API] Sleep type response data: ${response.data}');

      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices.map((e) => e['value'].toString()).toList();

      debugPrint('[SLEEP_API] Parsed sleep type values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[SLEEP_API] Error fetching sleep types: $e');
      debugPrint('[SLEEP_API] StackTrace: $stackTrace');
      return [];
    }
  }

  // Tags are LOCAL-ONLY - removed getTags() method
  // Tags are display-only and local-editable, no API calls needed
}
