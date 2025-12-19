import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ChildStatusBadge extends StatelessWidget {
  final bool isPresent;

  const ChildStatusBadge({
    super.key,
    required this.isPresent,
  });

  @override
  Widget build(BuildContext context) {
    if (isPresent) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.successLight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.done.svg(),
            const SizedBox(width: 4),
            const Text(
              'Present',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.errorLight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.xFill.svg(
              colorFilter: const ColorFilter.mode(
                AppColors.error,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Absent',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }
}

