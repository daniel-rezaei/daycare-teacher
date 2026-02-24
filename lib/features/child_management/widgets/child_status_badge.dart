import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/features/child_management/utils/child_status_helper.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ChildStatusBadgeWidget extends StatelessWidget {
  final ChildAttendanceStatus status;
  final bool hasNote; // آیا Note ثبت شده است یا نه

  const ChildStatusBadgeWidget({
    super.key,
    required this.status,
    this.hasNote = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChildAttendanceStatus.present:
        // اگر Note ثبت شده باشد، از استایل متفاوتی استفاده می‌کنیم
        if (hasNote) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xffFFEFD4), // #FFEFD4
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.images.done2.svg(),
                const SizedBox(width: 4),
                const Text(
                  'Present',
                  style: TextStyle(
                    color: Color(0xffED6009), // #ED6009
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        // فقط زمانی که بچه حاضر است و دکمه Check Out نمایش داده می‌شود
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
        // اگر هنوز نیامده و معلم باید انتخاب کند، badge نمایش داده نمی‌شود
        return const SizedBox.shrink();

      case ChildAttendanceStatus.checkedOut:
        // اگر امروز آمده و رفته، badge نمایش داده نمی‌شود
        return const SizedBox.shrink();

      case ChildAttendanceStatus.absent:
        // برای حالت غایب، badge نمایش داده نمی‌شود (ویجت Absent در سمت راست نمایش داده می‌شود)
        return const SizedBox.shrink();
    }
  }
}

