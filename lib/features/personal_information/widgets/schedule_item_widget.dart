import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/date_utils.dart';

class ScheduleItemWidget extends StatelessWidget {
  final String dayName;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final bool isFirst;

  const ScheduleItemWidget({
    super.key,
    required this.dayName,
    required this.date,
    this.startTime,
    this.endTime,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedStartTime = DateUtils.formatTime(startTime);
    final formattedEndTime = DateUtils.formatTime(endTime);
    final dateStr = DateFormat(AppConstants.displayDateFormat).format(date);

    return Container(
      decoration: BoxDecoration(
        color: isFirst ? AppColors.primaryLight : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: isFirst
            ? Border.all(
                color: AppColors.backgroundBorder,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: AppColors.shadowPurple.withValues(alpha: .5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            dayName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            formattedStartTime,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            DateUtils.getAmPm(formattedStartTime),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            ' - $formattedEndTime',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            DateUtils.getAmPm(formattedEndTime),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 1,
            height: 24,
            color: AppColors.divider,
          ),
          const SizedBox(width: 4),
          Text(
            dateStr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

