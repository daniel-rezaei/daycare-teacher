import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/features/auth/presentation/logout_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/widgets/upcoming_events_header_widget.dart';
import 'package:teacher_app/features/personal_information/utils/staff_schedule_helper.dart';
import 'package:teacher_app/features/personal_information/widgets/day_strip_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/mail_card_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/schedule_item_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/teacher_header_widget.dart';
import 'package:teacher_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';
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

    final startDateStr = DateFormat(AppConstants.dateFormat).format(startDate);
    final endDateStr = DateFormat(AppConstants.dateFormat).format(endDate);

    context.read<StaffAttendanceBloc>().add(
          GetStaffAttendanceByStaffIdEvent(
            staffId: widget.staffId,
            startDate: startDateStr,
            endDate: endDateStr,
          ),
        );
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
                  TeacherHeaderWidget(
                    teacherName: widget.teacherName,
                    teacherPhoto: widget.teacherPhoto,
                    className: widget.className,
                  ),
                  const SizedBox(height: 20),
                  Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite.withValues(alpha: .4),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, -4),
                                blurRadius: 16,
                                color: AppColors.shadowLight.withValues(alpha: .1),
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

                            // دریافت datetime کامل و استخراج فقط ساعت
                            String? checkInTime;
                            String? checkInAmPm;
                            String? checkOutTime;
                            String? checkOutAmPm;
                            
                            try {
                              final checkIn = attendanceList.firstWhere(
                                (attendance) =>
                                    attendance.eventType == 'time_in' &&
                                    attendance.eventAt != null &&
                                    DateUtils.isSameDate(attendance.eventAt!, selectedDate),
                              );
                              
                              if (checkIn.eventAt != null && checkIn.eventAt!.isNotEmpty) {
                                // Parse UTC time from API and convert to local for display
                                final dateTimeUtc = DateTime.parse(checkIn.eventAt!);
                                final dateTimeLocal = dateTimeUtc.toLocal();
                                checkInTime = DateFormat('h:mm').format(dateTimeLocal);
                                checkInAmPm = DateFormat('a').format(dateTimeLocal).toUpperCase();
                              }
                            } catch (e) {
                              // No check-in found
                            }
                            
                            try {
                              final checkOut = attendanceList.firstWhere(
                                (attendance) =>
                                    attendance.eventType == 'time_out' &&
                                    attendance.eventAt != null &&
                                    DateUtils.isSameDate(attendance.eventAt!, selectedDate),
                              );
                              
                              if (checkOut.eventAt != null && checkOut.eventAt!.isNotEmpty) {
                                // Parse UTC time from API and convert to local for display
                                final dateTimeUtc = DateTime.parse(checkOut.eventAt!);
                                final dateTimeLocal = dateTimeUtc.toLocal();
                                checkOutTime = DateFormat('h:mm').format(dateTimeLocal);
                                checkOutAmPm = DateFormat('a').format(dateTimeLocal).toUpperCase();
                              }
                            } catch (e) {
                              // No check-out found
                            }

                            return Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite
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
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    checkInTime ?? '--',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    checkInAmPm ?? '',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
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
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    checkOutTime ?? '--',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    checkOutAmPm ?? '',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
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
                            color: AppColors.backgroundWhite,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                                color: AppColors.shadowLight
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
                                        StaffScheduleHelper.getExpandedScheduleForCurrentWeek(
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
                                            color: AppColors.textPrimary,
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
                                            return ScheduleItemWidget(
                                              dayName: item['dayName'] as String,
                                              date: item['date'] as DateTime,
                                              startTime: item['startTime'] as String?,
                                              endTime: item['endTime'] as String?,
                                              isFirst: index == 0,
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
                                          color: AppColors.textPrimary,
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

// MailCardWidget and BackTitleWidget moved to separate files
