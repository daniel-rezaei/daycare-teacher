class StringUtils {
  StringUtils._();

  /// Capitalize the first letter of a string
  /// Returns empty string if input is null or empty
  /// Example: "father" -> "Father", "mother" -> "Mother"
  static String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) return '';
    if (text.length == 1) return text.toUpperCase();
    return text[0].toUpperCase() + text.substring(1);
  }
}

