import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ChildStatusActions extends StatelessWidget {
  final bool isPresent;
  final VoidCallback onPresentTap;
  final VoidCallback onAbsentTap;
  final VoidCallback onCheckOutTap;

  const ChildStatusActions({
    super.key,
    required this.isPresent,
    required this.onPresentTap,
    required this.onAbsentTap,
    required this.onCheckOutTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPresent) {
      // اگر حاضر است، دکمه Check Out و آیکون سه نقطه نمایش داده می‌شود
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MoreButton(),
        ],
      );
    } else {
      // اگر حاضر نیست، سه دکمه نمایش داده می‌شود: منو | سبز | قرمز
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MoreButton(),
          const SizedBox(width: 8),
          _ActionButton(
            color: AppColors.success,
            icon: Assets.images.done.svg(
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onTap: onPresentTap,
          ),
          const SizedBox(width: 8),
          _ActionButton(
            color: AppColors.error,
            icon: Assets.images.xFill.svg(
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onTap: onAbsentTap,
          ),
        ],
      );
    }
  }
}

class _MoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // فعلاً کاری نمی‌کند
      },
      child: Container(
        width: 32,
        height: 32,
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
        width: 32,
        height: 32,
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

