import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/utils/contact_utils.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_profile/child_profile_screen.dart';
import 'package:teacher_app/features/child_status/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_status/widgets/child_status_actions.dart';
import 'package:teacher_app/features/child_status/widgets/child_status_badge.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

class ChildStatusListItem extends StatelessWidget {
  final ChildEntity child;
  final ContactEntity? contact;
  final ChildAttendanceStatus status;
  final VoidCallback onPresentTap;
  final VoidCallback onAbsentTap;
  final VoidCallback onCheckOutTap;

  const ChildStatusListItem({
    super.key,
    required this.child,
    this.contact,
    required this.status,
    required this.onPresentTap,
    required this.onAbsentTap,
    required this.onCheckOutTap,
  });

  String get childName => ContactUtils.getContactName(contact);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 2,
          color: AppColors.backgroundBorder,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildProfileScreen(
                    childId: child.contactId ?? '',
                    childName: childName,
                    childPhoto: child.photo,
                  ),
                ),
              );
            },
            child: ChildAvatarWidget(
              photoId: child.photo,
              size: 48,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ChildStatusBadge(status: status),
              ],
            ),
          ),
          ChildStatusActions(
            status: status,
            onPresentTap: onPresentTap,
            onAbsentTap: onAbsentTap,
            onCheckOutTap: onCheckOutTap,
          ),
        ],
      ),
    );
  }
}

