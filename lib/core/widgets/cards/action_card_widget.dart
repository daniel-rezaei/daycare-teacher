import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/cards/base_card_widget.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

/// Action card widget for displaying actionable items with icon, title, and description
class ActionCardWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;
  final Widget? trailing;

  const ActionCardWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.onTap,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCardWidget(
      backgroundColor: backgroundColor ?? AppColors.backgroundWhite,
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      boxShadow: [
        BoxShadow(
          blurRadius: 4,
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 2),
        ),
      ],
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ] else ...[
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }
}
