import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/features/auth/presentation/logout_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/widgets/upcoming_events_header_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/day_strip_widget.dart';
import 'package:teacher_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/shift_date_entity.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/staff_schedule_entity.dart';
import 'package:teacher_app/features/staff_schedule/presentation/bloc/staff_schedule_bloc.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class PersonalInformationScreen extends StatefulWidget {
  final String teacherName;
  final String? teacherPhoto;
  final String className;
  final String staffId;
  final String contactId;

  const PersonalInformationScreen({
    super.key,
    required this.teacherName,
    this.teacherPhoto,
    required this.className,
    required this.staffId,
    required this.contactId,
  });

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  DateTime selectedDate = DateTime.now();
  bool _hasRequestedAttendance = false;
  bool _hasRequestedSchedule = false;
  bool _hasRequestedContact = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (!_hasRequestedContact && widget.contactId.isNotEmpty) {
      _hasRequestedContact = true;
      context.read<ProfileBloc>().add(GetContactEvent(id: widget.contactId));
    }

    if (!_hasRequestedAttendance && widget.staffId.isNotEmpty) {
      _hasRequestedAttendance = true;
      _loadAttendanceForDate(selectedDate);
    }

    if (!_hasRequestedSchedule && widget.staffId.isNotEmpty) {
      _hasRequestedSchedule = true;
      context.read<StaffScheduleBloc>().add(
            GetStaffScheduleByStaffIdEvent(staffId: widget.staffId),
          );
    }
  }

  void _loadAttendanceForDate(DateTime date) {
    if (widget.staffId.isEmpty) return;

    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    context.read<StaffAttendanceBloc>().add(
          GetStaffAttendanceByStaffIdEvent(
            staffId: widget.staffId,
            startDate: startDateStr,
            endDate: endDateStr,
          ),
        );
  }

  String _getPhotoUrl(String? photoId) {
    if (photoId == null || photoId.isEmpty) {
      return '';
    }
    return 'http://51.79.53.56:8055/assets/$photoId';
  }

  String? _getCheckInTime(List<StaffAttendanceEntity> attendanceList) {
    try {
      final checkIn = attendanceList.firstWhere(
        (attendance) =>
            attendance.eventType == 'time_in' &&
            attendance.eventAt != null &&
            _isSameDate(attendance.eventAt!, selectedDate),
      );

      if (checkIn.eventAt == null || checkIn.eventAt!.isEmpty) {
        return null;
      }

      final dateTime = DateTime.parse(checkIn.eventAt!);
      return DateFormat('h:mm').format(dateTime);
    } catch (e) {
      return null;
    }
  }

  String? _getCheckOutTime(List<StaffAttendanceEntity> attendanceList) {
    try {
      final checkOut = attendanceList.firstWhere(
        (attendance) =>
            attendance.eventType == 'time_out' &&
            attendance.eventAt != null &&
            _isSameDate(attendance.eventAt!, selectedDate),
      );

      if (checkOut.eventAt == null || checkOut.eventAt!.isEmpty) {
        return null;
      }

      final dateTime = DateTime.parse(checkOut.eventAt!);
      return DateFormat('h:mm').format(dateTime);
    } catch (e) {
      return null;
    }
  }

  String _getAmPm(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 'AM';
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      return hour >= 12 ? 'PM' : 'AM';
    } catch (e) {
      return 'AM';
    }
  }

  bool _isSameDate(String dateTimeStr, DateTime date) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return dateTime.year == date.year &&
          dateTime.month == date.month &&
          dateTime.day == date.day;
    } catch (e) {
      return false;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return '';
    }
  }

  // محاسبه دوشنبه هفته فعلی
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final daysFromMonday = weekday == 7 ? 0 : weekday - 1; // Sunday = 7, Monday = 1
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  // محاسبه یکشنبه هفته فعلی
  DateTime _getWeekEnd(DateTime date) {
    final weekStart = _getWeekStart(date);
    return weekStart.add(const Duration(days: 6));
  }

  // بررسی اینکه آیا schedule با هفته فعلی overlap دارد و فعال است
  bool _scheduleOverlapsWeek(
    StaffScheduleEntity schedule,
    DateTime weekStart,
    DateTime weekEnd,
  ) {
    if (schedule.startDate == null || schedule.startDate!.isEmpty) {
      return false;
    }

    try {
      final startDate = DateTime.parse(schedule.startDate!);
      final endDate = schedule.endDate != null && schedule.endDate!.isNotEmpty
          ? DateTime.parse(schedule.endDate!)
          : null;

      final now = DateTime.now();
      
      // بررسی اینکه schedule شروع شده و هنوز تمام نشده
      final isActive = startDate.isBefore(now.add(const Duration(days: 1))) &&
          (endDate == null || endDate.isAfter(now.subtract(const Duration(days: 1))));

      if (!isActive) return false;

      // بررسی overlap: start_date <= week_end AND (end_date >= week_start OR end_date is null)
      final hasOverlap = startDate.isBefore(weekEnd.add(const Duration(days: 1))) &&
          (endDate == null || endDate.isAfter(weekStart.subtract(const Duration(days: 1))));

      return hasOverlap;
    } catch (e) {
      return false;
    }
  }

  // تبدیل نام روز به index (Monday = 1, Sunday = 7)
  int _dayNameToIndex(String dayName) {
    const dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
      'all': 0, // برای همه روزها
    };
    return dayMap[dayName] ?? 1;
  }

  // محاسبه تاریخ واقعی یک روز خاص در هفته فعلی
  DateTime _getDateForWeekday(DateTime weekStart, int weekday) {
    // weekday: 1 = Monday, 7 = Sunday
    return weekStart.add(Duration(days: weekday - 1));
  }

  // تبدیل index به نام روز کامل
  String _indexToDayName(int index) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayNames[index - 1];
  }

  // فیلتر و expand کردن scheduleها برای هفته فعلی
  List<Map<String, dynamic>> _getExpandedScheduleForCurrentWeek(
    List<Map<String, dynamic>> schedulesWithShiftDate,
  ) {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = _getWeekEnd(now);

    final List<Map<String, dynamic>> expandedSchedules = [];

    for (var item in schedulesWithShiftDate) {
      final schedule = item['schedule'] as StaffScheduleEntity;
      final shiftDate = item['shiftDate'] as ShiftDateEntity;

      // بررسی overlap با هفته فعلی
      if (!_scheduleOverlapsWeek(schedule, weekStart, weekEnd)) {
        continue;
      }

      final daysOfWeek = shiftDate.daysOfWeek ?? [];
      if (daysOfWeek.isEmpty) {
        continue;
      }

      // Parse start_date و end_date
      DateTime? scheduleStartDate;
      DateTime? scheduleEndDate;

      try {
        if (schedule.startDate != null && schedule.startDate!.isNotEmpty) {
          scheduleStartDate = DateTime.parse(schedule.startDate!);
        }
        if (schedule.endDate != null && schedule.endDate!.isNotEmpty) {
          scheduleEndDate = DateTime.parse(schedule.endDate!);
        }
      } catch (e) {
        continue;
      }

      // اگر days_of_week شامل "all" است، همه روزهای هفته را اضافه کن
      if (daysOfWeek.contains('all')) {
        for (int weekday = 1; weekday <= 7; weekday++) {
          final actualDate = _getDateForWeekday(weekStart, weekday);

          // بررسی اینکه آیا این تاریخ در بازه [start_date, end_date] است
          if (scheduleStartDate != null && actualDate.isBefore(scheduleStartDate)) {
            continue;
          }
          if (scheduleEndDate != null && actualDate.isAfter(scheduleEndDate)) {
            continue;
          }

          // فقط روزهای گذشته و امروز را نمایش بده (نه روزهای آینده)
          if (actualDate.isAfter(now)) {
            continue;
          }

          expandedSchedules.add({
            'dayName': _indexToDayName(weekday),
            'date': actualDate,
            'startTime': shiftDate.startTime,
            'endTime': shiftDate.endTime,
            'schedule': schedule,
          });
        }
      } else {
        // Expand کردن روزهای مشخص شده در days_of_week
        for (var dayName in daysOfWeek) {
          final weekdayIndex = _dayNameToIndex(dayName);
          if (weekdayIndex == 0) continue; // skip "all" که قبلاً پردازش شد

          final actualDate = _getDateForWeekday(weekStart, weekdayIndex);

          // بررسی اینکه آیا این تاریخ در بازه [start_date, end_date] است
          if (scheduleStartDate != null && actualDate.isBefore(scheduleStartDate)) {
            continue;
          }
          if (scheduleEndDate != null && actualDate.isAfter(scheduleEndDate)) {
            continue;
          }

          // فقط روزهای گذشته و امروز را نمایش بده (نه روزهای آینده)
          if (actualDate.isAfter(now)) {
            continue;
          }

          expandedSchedules.add({
            'dayName': _indexToDayName(weekdayIndex),
            'date': actualDate,
            'startTime': shiftDate.startTime,
            'endTime': shiftDate.endTime,
            'schedule': schedule,
          });
        }
      }
    }

    // مرتب‌سازی بر اساس تاریخ (جدیدترین اول)
    expandedSchedules.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });

    return expandedSchedules;
  }


  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final time = DateTime.parse('2000-01-01 $timeStr');
      return DateFormat('h:mm').format(time);
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BackTitleWidget(
                    title: 'Personal Information',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Row(
                    children: [
                      Container(
                        height: 68,
                        width: 68,
                        margin: const EdgeInsets.only(left: 16),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: widget.teacherPhoto != null &&
                                widget.teacherPhoto!.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _getPhotoUrl(widget.teacherPhoto),
                                  httpHeaders: const {
                                    'Authorization':
                                        'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
                                  },
                                  width: 68,
                                  height: 68,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Assets.images.image.image(),
                                ),
                              )
                            : Assets.images.image.image(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            widget.teacherName,
                            style: const TextStyle(
                              color: Color(0xff444349),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffEFEEF0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                width: 2,
                                color: const Color(0xffFAFAFA),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: const Color(0xffE4D3FF)
                                      .withValues(alpha: .5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Assets.images.leftSlotItems.svg(),
                                const SizedBox(width: 8),
                                Text(
                                  widget.className,
                                  style: const TextStyle(
                                    color: Color(0xff681AD6),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFFFF).withValues(alpha: .4),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -4),
                          blurRadius: 16,
                          color: const Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DayStripWidget(
                          staffId: widget.staffId.isNotEmpty ? widget.staffId : null,
                          onDateSelected: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                            _loadAttendanceForDate(date);
                          },
                        ),
                        BlocBuilder<StaffAttendanceBloc, StaffAttendanceState>(
                          builder: (context, attendanceState) {
                            List<StaffAttendanceEntity> attendanceList = [];
                            if (attendanceState
                                is GetStaffAttendanceByStaffIdSuccess) {
                              attendanceList = attendanceState.attendanceList;
                            }

                            final checkInTime = _getCheckInTime(attendanceList);
                            final checkOutTime = _getCheckOutTime(attendanceList);

                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF)
                                    .withValues(alpha: .7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Assets.images.checkin.svg(),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Check_In',
                                    style: TextStyle(
                                      color: Color(0xff6D6B76),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    checkInTime ?? '--',
                                    style: const TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    checkInTime != null
                                        ? _getAmPm(checkInTime)
                                        : '',
                                    style: const TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Assets.images.checkout.svg(),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Check_Out',
                                    style: TextStyle(
                                      color: Color(0xff6D6B76),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    checkOutTime ?? '--',
                                    style: const TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    checkOutTime != null
                                        ? _getAmPm(checkOutTime)
                                        : '',
                                    style: const TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffFFFFFF),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                                color: const Color(0xff000000)
                                    .withValues(alpha: .1),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, profileState) {
                                  String email = '';
                                  String phone = '';

                                  if (profileState is GetContactSuccess) {
                                    email = profileState.contact.email ?? '';
                                    phone = profileState.contact.phone ?? '';
                                  }

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MailCardWidget(
                                        icon: Assets.images.mailbox.svg(),
                                        title: 'Email',
                                        subTitle: email.isNotEmpty
                                            ? email
                                            : 'Not available',
                                      ),
                                      const SizedBox(width: 12),
                                      MailCardWidget(
                                        icon: Assets.images.phoneRounded.svg(),
                                        title: 'Phone',
                                        subTitle: phone.isNotEmpty
                                            ? phone
                                            : 'Not available',
                                      ),
                                    ],
                                  );
                                },
                              ),
                              BlocBuilder<StaffScheduleBloc, StaffScheduleState>(
                                builder: (context, scheduleState) {
                                  if (scheduleState
                                      is GetStaffScheduleByStaffIdLoading) {
                                    return const SizedBox.shrink();
                                  }

                                  if (scheduleState
                                      is GetStaffScheduleByStaffIdSuccess) {
                                    final schedulesWithShiftDate =
                                        scheduleState.schedulesWithShiftDate;

                                    // فیلتر و expand کردن scheduleها برای هفته فعلی
                                    final expandedSchedules =
                                        _getExpandedScheduleForCurrentWeek(
                                            schedulesWithShiftDate);

                                    // اگر schedule وجود ندارد، تایتل و محتوا را نمایش نده
                                    if (expandedSchedules.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 32),
                                        const Text(
                                          'Schedule',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ListView.builder(
                                          itemCount: expandedSchedules.length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final item = expandedSchedules[index];
                                            final dayName = item['dayName'] as String;
                                            final date = item['date'] as DateTime;
                                            final startTime =
                                                _formatTime(item['startTime'] as String?);
                                            final endTime =
                                                _formatTime(item['endTime'] as String?);
                                            final dateStr = DateFormat('MMM d').format(date);

                                            return Container(
                                              decoration: BoxDecoration(
                                                color: index == 0
                                                    ? const Color(0xffF0E7FF)
                                                    : const Color(0xffFFFFFF),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: index == 0
                                                    ? Border.all(
                                                        color:
                                                            const Color(0xffFAFAFA),
                                                        width: 2,
                                                      )
                                                    : null,
                                                boxShadow: [
                                                  BoxShadow(
                                                    blurRadius: 8,
                                                    color: const Color(0xffE4D3FF)
                                                        .withValues(alpha: .5),
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 16,
                                              ),
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    dayName,
                                                    style: const TextStyle(
                                                      color: Color(0xff444349),
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    startTime,
                                                    style: const TextStyle(
                                                      color: Color(0xff444349),
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _getAmPm(startTime),
                                                    style: const TextStyle(
                                                      color: Color(0xff444349),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' - $endTime',
                                                    style: const TextStyle(
                                                      color: Color(0xff444349),
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _getAmPm(endTime),
                                                    style: const TextStyle(
                                                      color: Color(0xff444349),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    width: 1,
                                                    height: 24,
                                                    color: const Color(0xffDBDADD),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    dateStr,
                                                    style: const TextStyle(
                                                      color: Color(0xff444349),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                              const SizedBox(height: 32),
                              const UpcomingEventsHeaderWidget(),
                              const SizedBox(height: 32),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                      showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              useSafeArea: true,
              builder: (_) => const LogoutWidget(),
            );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Log Out',
                                        style: TextStyle(
                                          color: Color(0xff444349),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Assets.images.arrowRight.svg(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MailCardWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subTitle;
  const MailCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF7F7F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffFAFAFA), width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subTitle,
              style: const TextStyle(
                color: Color(0xff625F6A),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackTitleWidget extends StatelessWidget {
  final String title;
  final Function() onTap;
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
                color: Color(0xff444349),
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
