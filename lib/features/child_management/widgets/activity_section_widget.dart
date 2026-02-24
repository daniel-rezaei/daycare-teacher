import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/contact_utils.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ActivitySectionWidget extends StatelessWidget {
  final AttendanceChildEntity attendance;
  final ContactEntity? contact;
  final bool isCheckOut; // Explicit flag to know if this is a check-out card

  const ActivitySectionWidget({
    super.key,
    required this.attendance,
    this.contact,
    required this.isCheckOut,
  });

  String _getTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      // Parse UTC time from API and convert to local for display
      final dateTimeUtc = DateTime.parse(dateTimeStr);
      final dateTimeLocal = dateTimeUtc.toLocal();
      return DateFormat('hh:mm').format(dateTimeLocal);
    } catch (e) {
      return '';
    }
  }

  String _getAmPm(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'AM';
    try {
      // Parse UTC time from API and convert to local for display
      final dateTimeUtc = DateTime.parse(dateTimeStr);
      final dateTimeLocal = dateTimeUtc.toLocal();
      return DateFormat('a').format(dateTimeLocal).toUpperCase();
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
                      activityType == 'Check_In'
                          ? Assets.images.checkin.svg(
                             height: 32,
                            )
                          : Assets.images.checkout.svg(
                            height: 32,
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
                      attendance.checkInMethod!.isNotEmpty &&
                      attendance.checkInMethod == 'manually' &&
                      contact != null) ...[
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
                            'Brought By',
                            style: TextStyle(
                              color: Color(0xff6D6B76),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffE0E0E0),
                                ),
                                child: contact?.photo != null && contact!.photo!.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: '${AppConstants.assetsBaseUrl}/${contact!.photo}',
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.person,
                                            size: 20,
                                            color: Color(0xff6D6B76),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Color(0xff6D6B76),
                                      ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                ContactUtils.getContactName(contact),
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (activityType == 'Check_Out' && 
                      attendance.checkOutMethod != null && 
                      attendance.checkOutMethod!.isNotEmpty &&
                      attendance.checkOutMethod == 'manually') ...[
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
                            'Picked Up By',
                            style: TextStyle(
                              color: Color(0xff6D6B76),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffE0E0E0),
                                ),
                                child: contact?.photo != null && contact!.photo!.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: '${AppConstants.assetsBaseUrl}/${contact!.photo}',
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.person,
                                            size: 20,
                                            color: Color(0xff6D6B76),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Color(0xff6D6B76),
                                      ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                ContactUtils.getContactName(contact),
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
