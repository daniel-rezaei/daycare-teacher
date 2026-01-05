import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityAccidentApi {
  final Dio httpclient;
  ActivityAccidentApi(this.httpclient);

  /// Get field options from Child_Accident_Report table
  /// Returns list of choice texts from data.meta.options.choices[].text (for display)
  Future<List<String>> getFieldOptions(String fieldName) async {
    debugPrint(
      '[ACCIDENT_API] Fetching $fieldName options from /fields/Child_Accident_Report/$fieldName',
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

  // Note: Add button is not implemented yet, so no create methods needed
}
