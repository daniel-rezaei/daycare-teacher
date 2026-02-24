import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/features/child_status_module/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ProfileChildSectionWidget extends StatelessWidget {
  final String childName;
  final String? childPhoto;
  final String childId;

  const ProfileChildSectionWidget({
    super.key,
    required this.childName,
    this.childPhoto,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, state) {
        // پیدا کردن بچه از لیست children با contact_id
        String? dob;
        final children = state.children;
        if (children != null && children.isNotEmpty) {
          final child = children.firstWhere((c) => c.contactId == childId);
          dob = child.dob;
        }

        // Format date of birth: "2024-04-03" -> "April 3, 2024"
        final dobFormatted = dob != null && dob.isNotEmpty
            ? DateUtils.formatFullDisplayDate(dob)
            : 'Not available';
        return Row(
          children: [
            const SizedBox(width: 16),
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: ChildAvatarWidget(photoId: childPhoto, size: 68),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
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
                      Assets.images.gift.svg(),
                      const SizedBox(width: 8),
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 1,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.divider,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dobFormatted,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
