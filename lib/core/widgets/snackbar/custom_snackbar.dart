import 'package:flutter/material.dart';

/// Custom Snackbar utility for displaying consistent error and success messages
/// across the application.
class CustomSnackbar {
  /// Shows an error snackbar with red background and error icon
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a success snackbar with green background and check icon
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows an info snackbar with blue background and info icon
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a warning snackbar with orange background and warning icon
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows an error snackbar after closing a bottom sheet
  /// This is useful when you need to show an error from within a bottom sheet
  static void showErrorWithBottomSheet(BuildContext context, String message) {
    if (!context.mounted) return;
    
    // Close bottom sheet first if it exists
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      // Wait for bottom sheet to close, then show snackbar
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          showError(context, message);
        }
      });
    } else {
      // Show snackbar directly if no bottom sheet is open
      showError(context, message);
    }
  }

  /// Shows a success snackbar after closing a bottom sheet
  static void showSuccessWithBottomSheet(BuildContext context, String message) {
    if (!context.mounted) return;
    
    // Close bottom sheet first if it exists
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      // Wait for bottom sheet to close, then show snackbar
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          showSuccess(context, message);
        }
      });
    } else {
      // Show snackbar directly if no bottom sheet is open
      showSuccess(context, message);
    }
  }
}
