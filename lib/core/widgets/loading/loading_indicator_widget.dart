import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

/// Loading indicator widget with consistent styling
class LoadingIndicatorWidget extends StatelessWidget {
  final Color? color;
  final double? size;
  final String? message;

  const LoadingIndicatorWidget({
    super.key,
    this.color,
    this.size,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final effectiveSize = size ?? 24.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
