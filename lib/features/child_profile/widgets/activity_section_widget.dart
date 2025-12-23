import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ActivitySectionWidget extends StatelessWidget {
  final AttendanceChildEntity attendance;

  const ActivitySectionWidget({
    super.key,
    required this.attendance,
  });

  String _getTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('hh:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  String _getAmPm(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'AM';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('a').format(dateTime).toUpperCase();
    } catch (e) {
      return 'AM';
    }
  }

  String _getActivityType() {
    // اگر check_out_at وجود دارد، این یک Check Out است
    if (attendance.checkOutAt != null && attendance.checkOutAt!.isNotEmpty) {
      return 'Check_Out';
    }
    // در غیر این صورت Check In است
    return 'Check_In';
  }

  String? _getActivityTime() {
    if (attendance.checkOutAt != null && attendance.checkOutAt!.isNotEmpty) {
      return attendance.checkOutAt;
    }
    return attendance.checkInAt;
  }

  @override
  Widget build(BuildContext context) {
    final activityTime = _getActivityTime();
    final time = _getTime(activityTime);
    final amPm = _getAmPm(activityTime);
    final activityType = _getActivityType();

    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xffBAB9C0).withValues(alpha: .32),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time.isNotEmpty ? time : '--:--',
                style: TextStyle(
                  color: Color(0xff444349),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                amPm,
                style: TextStyle(
                  color: Color(0xff6D6B76),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(width: 22),
          Container(
            height: 112,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Color(0xffDBDADD)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: activityType == 'Check_In' 
                              ? Color(0xffEFFAFF) 
                              : Color(0xffFFF4E6),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(6),
                        child: Assets.images.subtract.svg(
                          colorFilter: ColorFilter.mode(
                            activityType == 'Check_In' 
                                ? Color(0xff4A90E2) 
                                : Color(0xffFF9500),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        activityType,
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (activityType == 'Check_In' && 
                      attendance.checkInMethod != null && 
                      attendance.checkInMethod!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffF7F7F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Method',
                            style: TextStyle(
                              color: Color(0xff6D6B76),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            attendance.checkInMethod == 'barcode' 
                                ? 'Barcode' 
                                : attendance.checkInMethod == 'manually'
                                    ? 'Manual'
                                    : attendance.checkInMethod!,
                            style: TextStyle(
                              color: Color(0xff444349),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (activityType == 'Check_Out' && 
                      attendance.checkOutMethod != null && 
                      attendance.checkOutMethod!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffF7F7F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Method',
                            style: TextStyle(
                              color: Color(0xff6D6B76),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            attendance.checkOutMethod == 'barcode' 
                                ? 'Barcode' 
                                : attendance.checkOutMethod == 'manually'
                                    ? 'Manual'
                                    : attendance.checkOutMethod!,
                            style: TextStyle(
                              color: Color(0xff444349),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
