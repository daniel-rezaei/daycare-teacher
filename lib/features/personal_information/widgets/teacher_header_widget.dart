import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TeacherHeaderWidget extends StatelessWidget {
  final String teacherName;
  final String? teacherPhoto;
  final String className;

  const TeacherHeaderWidget({
    super.key,
    required this.teacherName,
    this.teacherPhoto,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 68,
          width: 68,
          margin: const EdgeInsets.only(left: 16),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: teacherPhoto != null && teacherPhoto!.isNotEmpty
              ? ChildAvatarWidget(
                  photoId: teacherPhoto,
                  size: 68,
                )
              : Assets.images.image.image(),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Text(
              teacherName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 2,
                  color: AppColors.backgroundBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: AppColors.shadowPurple.withValues(alpha: .5),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Assets.images.leftSlotItems.svg(),
                  const SizedBox(width: 8),
                  Text(
                    className,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

