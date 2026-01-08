import 'package:teacher_app/core/constants/app_constants.dart';

class PhotoUtils {
  PhotoUtils._();

  /// Get full photo URL from photo ID
  static String getPhotoUrl(String? photoId) {
    if (photoId == null || photoId.isEmpty) {
      return '';
    }
    return '${AppConstants.assetsBaseUrl}/$photoId';
  }

  /// Get authorization header for image requests
  static Map<String, String> getImageHeaders() {
    return {'Authorization': 'Bearer ${AppConstants.bearerToken}'};
  }
}
