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
}

