import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityAccidentApi {
  final Dio httpclient;
  ActivityAccidentApi(this.httpclient);

  /// Get field options from child_accident_report table
  /// Returns list of choice values from data.meta.options.choices[].value
  Future<List<String>> getFieldOptions(String fieldName) async {
    debugPrint(
      '[ACCIDENT_API] Fetching $fieldName options from /fields/child_accident_report/$fieldName',
    );
    try {
      final response = await httpclient.get(
        '/fields/child_accident_report/$fieldName',
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

      final values = choices.map((e) => e['value'].toString()).toList();

      debugPrint('[ACCIDENT_API] Parsed $fieldName values: $values');
      return values;
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

  /// Get date notified options (if exists)
  Future<List<String>> getDateNotifiedOptions() async {
    return getFieldOptions('date_time_notified');
  }

  // Note: Add button is not implemented yet, so no create methods needed
}
