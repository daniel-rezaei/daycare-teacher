import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/child_avatar_widget.dart';
import 'package:teacher_app/core/utils/contact_utils.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/screens/child_profile_screen.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_profile_bloc.dart';
import 'package:teacher_app/features/child_management/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_management/widgets/child_status_actions.dart';
import 'package:teacher_app/features/child_management/widgets/child_status_badge.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/class_transfer_request_entity.dart';

class ChildStatusListItemWidget extends StatelessWidget {
  final ChildEntity child;
  final ContactEntity? contact;
  final ChildAttendanceStatus status;
  final AttendanceChildEntity? attendance; // برای نمایش زمان check_out_at
  final String currentClassId; // Current teacher's class ID
  final ClassTransferRequestEntity? transferRequest; // Transfer request if exists
  final VoidCallback onPresentTap;
  final VoidCallback onAbsentTap;
  final VoidCallback onCheckOutTap;
  final void Function(String childId, String childName, String? childPhoto)? onMoreTap;
  final VoidCallback? onAcceptTransfer;
  final VoidCallback? onDeclineTransfer;

  const ChildStatusListItemWidget({
    super.key,
    required this.child,
    this.contact,
    required this.status,
    this.attendance,
    required this.currentClassId,
    this.transferRequest,
    required this.onPresentTap,
    required this.onAbsentTap,
    required this.onCheckOutTap,
    this.onMoreTap,
    this.onAcceptTransfer,
    this.onDeclineTransfer,
  });

  String get childName => ContactUtils.getContactName(contact);

  /// Check if this teacher is the destination class teacher (can accept/decline)
  bool get _isDestinationTeacher {
    return transferRequest != null &&
        transferRequest!.toClassId == currentClassId &&
        transferRequest!.status == 'pending';
  }

  /// Check if student has a pending transfer request from current teacher's class
  bool get _hasPendingTransferFromCurrentClass {
    return transferRequest != null &&
        transferRequest!.fromClassId == currentClassId &&
        transferRequest!.status == 'pending';
  }

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
            onTap: () async {
              // Preload medical data BEFORE navigation
              final actualChildId = child.id;
              if (actualChildId != null && actualChildId.isNotEmpty) {
                // Dispatch preload event
                context.read<ChildProfileBloc>().add(
                      PreloadChildMedicalDataEvent(childId: actualChildId),
                    );

                // Wait for data to load
                await context.read<ChildProfileBloc>().stream.firstWhere(
                      (state) => state is ChildProfileDataLoaded || state is ChildProfileError,
                    ).timeout(
                      const Duration(seconds: 10),
                      onTimeout: () => const ChildProfileError('Timeout loading medical data'),
                    );

                // Navigate only after data is loaded
                if (context.mounted) {
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
                }
              } else {
                // Fallback: navigate immediately if childId is not available
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
              }
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Show transfer status FIRST if there's a pending request from current class
                if (_hasPendingTransferFromCurrentClass)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Pending review',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  // Only show attendance badge if no pending transfer request
                  ChildStatusBadgeWidget(
                    status: status,
                    hasNote: attendance?.notes != null && attendance!.notes!.isNotEmpty,
                  ),
              ],
            ),
          ),
          // Show Accept/Decline buttons for destination teachers
          if (_isDestinationTeacher)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TransferActionButton(
                  text: 'Accept',
                  color: AppColors.primary,
                  onTap: onAcceptTransfer,
                ),
                const SizedBox(width: 8),
                _TransferActionButton(
                  text: 'Decline',
                  color: Colors.red,
                  onTap: onDeclineTransfer,
                ),
              ],
            )
          // Show normal actions if no transfer request or not destination teacher
          else if (!_hasPendingTransferFromCurrentClass)
            ChildStatusActionsWidget(
              status: status,
              checkOutAt: attendance?.checkOutAt,
              onPresentTap: onPresentTap,
              onAbsentTap: onAbsentTap,
              onCheckOutTap: onCheckOutTap,
              onMoreTap: onMoreTap,
              childId: child.id,
              childName: childName,
              childPhoto: child.photo,
            ),
        ],
      ),
    );
  }
}

class _TransferActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onTap;

  const _TransferActionButton({
    required this.text,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

