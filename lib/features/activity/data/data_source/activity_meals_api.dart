import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityMealsApi {
  final Dio httpclient;
  ActivityMealsApi(this.httpclient);

  /// Create a meal activity entry
  /// Fields must match exact API casing: activity_meals.date_time, activity_meals.meal_type, activity_meals.quantity
  /// NOTE: activity_meals.tag is LOCAL-ONLY and NOT sent to API
  Future<Response> createMealActivity({
    required String childId,
    required String dateTime, // activity_meals.date_time
    required String mealType, // activity_meals.meal_type
    required String quantity, // activity_meals.quantity
    // Tags are LOCAL-ONLY - removed from API parameters
    String? description,
    String? photo, // file ID
  }) async {
    debugPrint('[MEAL_API] ========== Creating Meal Activity ==========');
    debugPrint('[MEAL_API] childId: $childId');
    debugPrint('[MEAL_API] date_time: $dateTime');
    debugPrint('[MEAL_API] meal_type: $mealType');
    debugPrint('[MEAL_API] quantity: $quantity');
    debugPrint('[MEAL_API] tag: NOT INCLUDED (tags are LOCAL-ONLY)');
    debugPrint('[MEAL_API] description: $description');
    debugPrint('[MEAL_API] photo: $photo');

    final data = <String, dynamic>{
      'child_id': childId,
      'date_time': dateTime, // Exact field name from API
      'meal_type': mealType, // Exact field name from API
      'quantity': quantity, // Exact field name from API
    };

    // Tags are LOCAL-ONLY - NOT included in API payload
    // Removed tag handling - tags are display-only and local-editable

    if (description != null && description.isNotEmpty) {
      data['description'] = description;
    }

    if (photo != null && photo.isNotEmpty) {
      data['photo'] = photo;
    }

    debugPrint('[MEAL_API] Request data: $data');

    try {
      final response = await httpclient.post(
        '/items/activity_meals',
        data: data,
      );
      debugPrint('[MEAL_API] Response status: ${response.statusCode}');
      debugPrint('[MEAL_API] Response data: ${response.data}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[MEAL_API] Error creating meal activity: $e');
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
}

