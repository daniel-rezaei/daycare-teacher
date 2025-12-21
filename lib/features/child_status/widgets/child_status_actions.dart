import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/features/child_status/utils/child_status_helper.dart';
import 'package:teacher_app/gen/assets.gen.dart';
import 'package:intl/intl.dart';

class ChildStatusActions extends StatelessWidget {
  final ChildAttendanceStatus status;
  final String? checkOutAt; // زمان check-out برای نمایش
  final VoidCallback onPresentTap;
  final VoidCallback onAbsentTap;
  final VoidCallback onCheckOutTap;
  final VoidCallback? onMoreTap;

  const ChildStatusActions({
    super.key,
    required this.status,
    this.checkOutAt,
    required this.onPresentTap,
    required this.onAbsentTap,
    required this.onCheckOutTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChildAttendanceStatus.present:
        // اگر حاضر است، فقط دکمه Check Out نمایش داده می‌شود
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onCheckOutTap,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: const Text(
                  'Check Out',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _MoreButton(onTap: onMoreTap),
          ],
        );

      case ChildAttendanceStatus.notArrived:
        // اگر هنوز نیامده، دکمه‌های Present و Absent نمایش داده می‌شود
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MoreButton(onTap: onMoreTap),
            const SizedBox(width: 8),
            _ActionButton(
              color: Color(0xffDAFEE8),
              icon: Assets.images.done.svg(
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Color(0xff0EAB52),
                  BlendMode.srcIn,
                ),
              ),
              onTap: onPresentTap,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              color: Color(0xffFFDFDF),
              icon: Assets.images.xFill.svg(
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Color(0xffED1515),
                  BlendMode.srcIn,
                ),
              ),
              onTap: onAbsentTap,
            ),
          ],
        );

      case ChildAttendanceStatus.checkedOut:
        // اگر امروز آمده و رفته، "Checked out" نمایش داده می‌شود
        String checkedOutText = 'Checked out';
        if (checkOutAt != null && checkOutAt!.isNotEmpty) {
          try {
            final checkOutDateTime = DateTime.parse(checkOutAt!);
            final timeFormat = DateFormat('HH:mm');
            checkedOutText = 'Checked out at ${timeFormat.format(checkOutDateTime)}';
          } catch (e) {
            // اگر parse نشد، فقط "Checked out" نمایش می‌دهیم
            checkedOutText = 'Checked out';
          }
        }
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MoreButton(onTap: onMoreTap),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                checkedOutText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        );

      case ChildAttendanceStatus.absent:
        // اگر غایب است، فقط ویجت Absent نمایش داده می‌شود
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xffFFDFDF),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Assets.images.xFill.svg(
                colorFilter: const ColorFilter.mode(
                  Colors.redAccent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Absent',
                style: TextStyle(
                  color: Color(0xffED1515),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MoreButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.more_vert,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}

