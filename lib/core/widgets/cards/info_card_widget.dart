import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/cards/base_card_widget.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

/// Info card widget for displaying information with icon and text
class InfoCardWidget extends StatelessWidget {
  final Color color;
  final Widget icon;
  final Widget title;
  final String description;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const InfoCardWidget({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BaseCardWidget(
        backgroundColor: color,
        border: Border.all(width: 2, color: AppColors.backgroundBorder),
        borderRadius: 16,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 30),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffEFFAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    child: title,
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
