import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/features/child_status/utils/child_status_helper.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ChildStatusBadge extends StatelessWidget {
  final ChildAttendanceStatus status;

  const ChildStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChildAttendanceStatus.present:
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

      case ChildAttendanceStatus.notArrived:
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

      case ChildAttendanceStatus.checkedOut:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.done.svg(
                colorFilter: ColorFilter.mode(
                  AppColors.textSecondary.withValues(alpha: 0.6),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Checked Out',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
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

