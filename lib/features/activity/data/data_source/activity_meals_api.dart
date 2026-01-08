import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityMealsApi {
  final Dio httpclient;
  ActivityMealsApi(this.httpclient);

  /// Get activity type ID from backend based on type
  Future<String> _getActivityTypeId(String type) async {
    debugPrint('[MEAL_API] Fetching activity type ID for type: $type');
    final response = await httpclient.get('/items/activity_types');
    final data = response.data['data'] as List<dynamic>;
    
    for (final item in data) {
      if (item['type'] == type) {
        final id = item['id'] as String;
        debugPrint('[MEAL_API] Found activity type ID for $type: $id');
        return id;
      }
    }
    
    throw Exception('[MEAL_API] Activity type not found for: $type');
  }

  /// STEP A: Create parent activity record
  /// Returns the activity ID to be used for creating meal details
  /// Uses UUID-based M2M pivot tables (no integer ID conversion needed)
  Future<String> createActivity({
    required String childId,
    required String classId,
    required String startAtUtc,
  }) async {
    debugPrint('[MEAL_API] ========== STEP A: Creating Activity (Parent) ==========');

    // Get activity type ID from backend
    final activityTypeId = await _getActivityTypeId('meal');

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

    debugPrint('[MEAL_API] Activity request data: $data');

    final response = await httpclient.post('/items/activities', data: data);

    final activityId = response.data['data']['id'] as String;
    debugPrint('[MEAL_API] ✅ Activity created with ID: $activityId');

    return activityId;
  }

  /// STEP B: Create meal details (child record) linked to activity
  /// Tags are now included in the API payload as per backend requirements
  Future<Response> createMealDetails({
    required String activityId,
    required String mealType,
    required String quantity,
    String? description,
    List<String>? tags,
    String? photo, // file ID
  }) async {
    debugPrint('[MEAL_API] ========== STEP B: Creating Meal Details (Child) ==========');
    debugPrint('[MEAL_API] activityId: $activityId');
    debugPrint('[MEAL_API] meal_type: $mealType');
    debugPrint('[MEAL_API] quantity: $quantity');
    debugPrint('[MEAL_API] tags: $tags');
    debugPrint('[MEAL_API] description: $description');
    debugPrint('[MEAL_API] photo: $photo');

    final data = <String, dynamic>{
      'activity_id': activityId,
      'meal_type': mealType,
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

    debugPrint('[MEAL_API] Meal details request data: $data');

    debugPrint('================= DIRECTUS RAW BODY =================');
    debugPrint(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint('=====================================================');

    try {
      final response = await httpclient.post(
        '/items/activity_meals',
        data: data,
      );
      debugPrint('[MEAL_API] Meal details response status: ${response.statusCode}');
      debugPrint('[MEAL_API] Meal details response data: ${response.data}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[MEAL_API] Error creating meal details: $e');
      debugPrint('[MEAL_API] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get meal type options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getMealTypes() async {
    debugPrint('[MEAL_API] Fetching meal type options from /fields/activity_meals/meal_type');
    try {
      final response = await httpclient.get('/fields/activity_meals/meal_type');
      debugPrint('[MEAL_API] Meal type response status: ${response.statusCode}');
      debugPrint('[MEAL_API] Meal type response data: ${response.data}');
      
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices
          .map((e) => e['value'].toString())
          .toList();

      debugPrint('[MEAL_API] Parsed meal type values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[MEAL_API] Error fetching meal types: $e');
      debugPrint('[MEAL_API] StackTrace: $stackTrace');
      return [];
    }
  }

  /// Get quantity options from field metadata
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getQuantities() async {
    debugPrint('[MEAL_API] Fetching quantity options from /fields/activity_meals/quantity');
    try {
      final response = await httpclient.get('/fields/activity_meals/quantity');
      debugPrint('[MEAL_API] Quantity response status: ${response.statusCode}');
      debugPrint('[MEAL_API] Quantity response data: ${response.data}');
      
      final root = response.data as Map<String, dynamic>;
      final data = root['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final options = meta['options'] as Map<String, dynamic>;
      final choices = options['choices'] as List<dynamic>;

      final values = choices
          .map((e) => e['value'].toString())
          .toList();

      debugPrint('[MEAL_API] Parsed quantity values: $values');
      return values;
    } catch (e, stackTrace) {
      debugPrint('[MEAL_API] Error fetching quantities: $e');
      debugPrint('[MEAL_API] StackTrace: $stackTrace');
      return [];
    }
  }

  // Tags are LOCAL-ONLY - removed getTags() method
  // Tags are display-only and local-editable, no API calls needed

  /// Get activity history for a given class
  /// Returns true if at least one activity exists, false otherwise
  Future<bool> hasHistory(String classId) async {
    debugPrint('[MEAL_API] ========== Checking history for classId: $classId ==========');
    try {
      final activityTypeId = await _getActivityTypeId('meal');
      debugPrint('[MEAL_API] Activity type ID: $activityTypeId');
      
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
      
      debugPrint('[MEAL_API] ========== History check result: $hasHistory (found ${data.length} items) ==========');
      return hasHistory;
    } catch (e, stackTrace) {
      debugPrint('[MEAL_API] Error checking history: $e');
      debugPrint('[MEAL_API] StackTrace: $stackTrace');
      return false; // On error, assume no history to show children list
    }
  }
}

