import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/buttons/primary_button_widget.dart';

/// Loading button widget that wraps PrimaryButtonWidget with loading state
/// This is a convenience widget for buttons that need loading state
class LoadingButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;

  const LoadingButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButtonWidget(
      onPressed: isLoading ? null : onPressed,
      text: text,
      isLoading: isLoading,
      isEnabled: isEnabled,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    );
  }
}
