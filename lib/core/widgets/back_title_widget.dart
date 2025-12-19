import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class BackTitleWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const BackTitleWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              color: Colors.transparent,
              child: Assets.images.arrowLeft2.svg(),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

