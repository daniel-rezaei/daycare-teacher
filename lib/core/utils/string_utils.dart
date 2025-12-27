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

  /// Format phone number to Canadian standard format: +1 (XXX) XXX-XXXX
  /// Normalizes various input formats:
  /// - +14161234567 → +1 (416) 123-4567
  /// - 4161234567 → +1 (416) 123-4567
  /// - (416)1234567 → +1 (416) 123-4567
  /// - 416-123-4567 → +1 (416) 123-4567
  /// Returns empty string if input is null, empty, or invalid (not 10 digits)
  static String formatCanadianPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Extract only digits from the input (remove all non-digit characters)
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different input formats
    String tenDigits = digitsOnly;
    
    if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // Format: 14161234567 (with leading 1)
      tenDigits = digitsOnly.substring(1);
    } else if (digitsOnly.length == 10) {
      // Format: 4161234567 (10 digits, no leading 1)
      tenDigits = digitsOnly;
    } else {
      // Invalid length - return original (might be international or malformed)
      return phone;
    }

    // Validate: must be exactly 10 digits for Canadian phone number
    if (tenDigits.length != 10) {
      // If invalid, return original (might be international or malformed)
      return phone;
    }

    // Format as +1 (XXX) XXX-XXXX
    final areaCode = tenDigits.substring(0, 3);
    final firstPart = tenDigits.substring(3, 6);
    final secondPart = tenDigits.substring(6, 10);

    return '+1 ($areaCode) $firstPart-$secondPart';
  }
}

