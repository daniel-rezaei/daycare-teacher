import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

class ModalBottomSheetWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ModalBottomSheetWrapper({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, -4),
              color: AppColors.dividerDark.withValues(alpha: .2),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

