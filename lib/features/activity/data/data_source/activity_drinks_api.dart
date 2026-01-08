import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityDrinksApi {
  final Dio httpclient;
  ActivityDrinksApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[DRINK_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;
    
    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[DRINK_API] Found activity type ID for $type: $id');
        return id;
      }
    }
    
    throw Exception('[DRINK_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating drink details
  /// Uses UUID-based M2M pivot tables (no integer ID conversion needed)
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    debugPrint('[DRINK_API] ========== STEP A: Creating Activity (Parent) ==========');

    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('drink');

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

    debugPrint('[DRINK_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[DRINK_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create drink details (child record) linked to activity
  /// Tags are now included in the API payload as per backend requirements
  Future<Response> createDrinkDetails({
    required String activityId,
    required String drinkType,
    required String quantity,
    String? description,
    List<String>? tags,
    String? photo, // file ID
  }) async {
    debugPrint('[DRINK_API] ========== STEP B: Creating Drink Details (Child) ==========');
    debugPrint('[DRINK_API] activityId: $activityId');
    debugPrint('[DRINK_API] drink_type: $drinkType');
    debugPrint('[DRINK_API] quantity: $quantity');
    debugPrint('[DRINK_API] tags: $tags');
    debugPrint('[DRINK_API] description: $description');
    debugPrint('[DRINK_API] photo: $photo');

    final data = <String, dynamic>{
      'activity_id': activityId,
      'drink_type': drinkType,
      'quantity': quantity,
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

    debugPrint('[DRINK_API] Drink details request data: $data');

    debugPrint('================= DIRECTUS RAW BODY =================');
    debugPrint(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/activity_drinks',
        data: data,
      );
      debugPrint('[DRINK_API] Drink details response status: ${response.statusCode}');
      debugPrint('[DRINK_API] Drink details response data: ${response.data}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[DRINK_API] Error creating drink details: $e');
      debugPrint('[DRINK_API] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get drink type options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getDrinkTypes() async {
    debugPrint('[DRINK_API] Fetching drink type options from /fields/activity_drinks/type');
    try {
      final response = await httpclient.get('/fields/activity_drinks/type');
      debugPrint('[DRINK_API] Drink type response status: ${response.statusCode}');
      debugPrint('[DRINK_API] Drink type response data: ${response.data}');
      
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices
          .map((e) => e['value'].toString())
          .toList();

      debugPrint('[DRINK_API] Parsed drink type values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[DRINK_API] Error fetching drink types: $e');
      debugPrint('[DRINK_API] StackTrace: $stackTrace');
      return [];
    }
  }

  /// Get quantity options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getQuantities() async {
    debugPrint('[DRINK_API] Fetching quantity options from /fields/activity_drinks/quantity');
    try {
      final response = await httpclient.get('/fields/activity_drinks/quantity');
      debugPrint('[DRINK_API] Quantity response status: ${response.statusCode}');
      debugPrint('[DRINK_API] Quantity response data: ${response.data}');
      
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices
          .map((e) => e['value'].toString())
          .toList();

      debugPrint('[DRINK_API] Parsed quantity values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[DRINK_API] Error fetching quantities: $e');
      debugPrint('[DRINK_API] StackTrace: $stackTrace');
      return [];
    }
  }

  // Tags are LOCAL-ONLY - removed getTags() method
  // Tags are display-only and local-editable, no API calls needed

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
    debugPrint('[DRINK_API] ========== Checking history for classId: $classId ==========');
    try {
      final activityTypeId = await _getActivityTypeId('drink');
      debugPrint('[DRINK_API] Activity type ID: $activityTypeId');
      
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
      
      debugPrint('[DRINK_API] ========== History check result: $hasHistory (found ${data.length} items) ==========');
      return hasHistory;
    } catch (e, stackTrace) {
      debugPrint('[DRINK_API] Error checking history: $e');
      debugPrint('[DRINK_API] StackTrace: $stackTrace');
      return false; // On error, assume no history to show children list
    }
  }
}

