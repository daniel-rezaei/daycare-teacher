import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

class MailCardWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subTitle;
  
  const MailCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLighter,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.backgroundBorder, width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subTitle,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

