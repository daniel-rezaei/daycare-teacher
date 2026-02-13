import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

/// Secondary button widget with outlined style
class SecondaryButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Widget? icon;

  const SecondaryButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 52,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;
    final effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
    final isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    return GestureDetector(
      onTap: isButtonEnabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isButtonEnabled ? 1.0 : 0.5,
        child: Container(
          height: height,
          width: width ?? double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveBorderColor,
              width: 2,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: effectiveTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
