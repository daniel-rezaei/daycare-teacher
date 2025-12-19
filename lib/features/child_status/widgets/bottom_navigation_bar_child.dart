import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

class BottomNavigationBarChild extends StatelessWidget {
  const BottomNavigationBarChild({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Done',
            style: TextStyle(
              color: AppColors.backgroundBorder,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
