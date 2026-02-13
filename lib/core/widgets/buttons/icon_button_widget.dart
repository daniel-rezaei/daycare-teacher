import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

/// Icon button widget with consistent styling
class IconButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isEnabled;
  final String? tooltip;

  const IconButtonWidget({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 36,
    this.backgroundColor,
    this.iconColor,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.backgroundWhite;
    final effectiveIconColor = iconColor ?? AppColors.textPrimary;
    final isButtonEnabled = isEnabled && onPressed != null;

    Widget button = GestureDetector(
      onTap: isButtonEnabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isButtonEnabled ? 1.0 : 0.5,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size * 0.55,
            color: effectiveIconColor,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
