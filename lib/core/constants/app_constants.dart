class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'http://51.79.53.56:8055';
  static const String assetsBaseUrl = '$baseUrl/assets';
  static const String bearerToken = 'ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM';
  
  // SharedPreferences Keys
  static const String classIdKey = 'class_id';
  static const String staffIdKey = 'staff_id';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Date Formats
  static const String dateTimeFormat = 'yyyy-MM-ddTHH:mm:ss';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM d';
  static const String fullDisplayDateFormat = 'MMMM d, yyyy';
  static const String timeFormat = 'h:mm';
  
  // Default Values
  static const String unknownName = 'Unknown';
  static const String unknownContact = 'Unknown';
}

