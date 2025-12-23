import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/contact_utils.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_profile/widgets/activity_section_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/day_strip_widget.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

// Helper class برای نگهداری اطلاعات فعالیت
class _ActivityItem {
  final AttendanceChildEntity attendance;
  final bool isCheckOut;
  final String time;

  _ActivityItem({
    required this.attendance,
    required this.isCheckOut,
    required this.time,
  });
}

class ContentActivity extends StatefulWidget {
  final String childId; // contactId

  const ContentActivity({super.key, required this.childId});

  @override
  State<ContentActivity> createState() => _ContentActivityState();
}

class _ContentActivityState extends State<ContentActivity> {
  DateTime _selectedDate = DateTime.now();
  String? _actualChildId;
  String? _classId;
  bool _hasRequestedAttendance = false;

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  Future<void> _loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString(AppConstants.classIdKey);
    
    if (mounted) {
      setState(() {
        _classId = savedClassId;
      });
      
      // پیدا کردن actualChildId از ChildBloc
      final childState = context.read<ChildBloc>().state;
      if (childState.children != null) {
        try {
          final foundChild = childState.children!.firstWhere(
            (c) => c.contactId == widget.childId,
          );
          if (mounted) {
            setState(() {
              _actualChildId = foundChild.id;
            });
            _loadAttendance();
          }
        } catch (e) {
          debugPrint('[CONTENT_ACTIVITY] Child not found with contactId: ${widget.childId}');
        }
      }
    }
  }

  void _loadAttendance() {
    if (_classId != null && _actualChildId != null && !_hasRequestedAttendance) {
      _hasRequestedAttendance = true;
      context.read<AttendanceBloc>().add(
        GetAttendanceByClassIdEvent(
          classId: _classId!,
          childId: _actualChildId,
        ),
      );
      
      // Load staff classes if not already loaded
      final authState = context.read<AuthBloc>().state;
      if (authState is! GetStaffClassSuccess && _classId != null) {
        context.read<AuthBloc>().add(GetStaffClassEvent(classId: _classId!));
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // در صورت نیاز می‌توانیم attendance را دوباره دریافت کنیم
    // اما چون قبلاً همه attendance ها را دریافت کرده‌ایم، فقط فیلتر می‌کنیم
  }

  // ساخت لیست فعالیت‌ها برای یک تاریخ خاص
  // هر attendance می‌تواند دو فعالیت داشته باشد: Check In و Check Out
  List<_ActivityItem> _getActivitiesForDate(
    List<AttendanceChildEntity> allAttendance,
    DateTime date,
  ) {
    if (_actualChildId == null) return [];
    
    final activities = <_ActivityItem>[];
    
    for (final attendance in allAttendance) {
      if (attendance.childId != _actualChildId) continue;
      
      // بررسی check_in_at
      if (attendance.checkInAt != null && attendance.checkInAt!.isNotEmpty) {
        if (DateUtils.isSameDate(attendance.checkInAt!, date)) {
          activities.add(_ActivityItem(
            attendance: attendance,
            isCheckOut: false,
            time: attendance.checkInAt!,
          ));
        }
      }
      
      // بررسی check_out_at
      if (attendance.checkOutAt != null && attendance.checkOutAt!.isNotEmpty) {
        if (DateUtils.isSameDate(attendance.checkOutAt!, date)) {
          activities.add(_ActivityItem(
            attendance: attendance,
            isCheckOut: true,
            time: attendance.checkOutAt!,
          ));
        }
      }
    }
    
    // مرتب‌سازی بر اساس زمان (جدیدترین اول)
    activities.sort((a, b) {
      try {
        final aDate = DateTime.parse(a.time);
        final bDate = DateTime.parse(b.time);
        return bDate.compareTo(aDate);
      } catch (e) {
        return 0;
      }
    });
    
    return activities;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, childState) {
        // پیدا کردن actualChildId اگر هنوز پیدا نشده
        if (_actualChildId == null && childState.children != null) {
          try {
            final foundChild = childState.children!.firstWhere(
              (c) => c.contactId == widget.childId,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _actualChildId = foundChild.id;
                });
                _loadAttendance();
              }
            });
          } catch (e) {
            // Child not found yet
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: Color(0xffFFFFFF).withValues(alpha: .4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -4),
                blurRadius: 16,
                color: Color(0xff000000).withValues(alpha: .1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DayStripWidget(
                onDateSelected: _onDateSelected,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffFFFFFF).withValues(alpha: .8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff000000).withValues(alpha: .1),
                      offset: Offset(0, -4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(16, 16, 16, 36),
                child: BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, attendanceState) {
                    List<AttendanceChildEntity> attendanceList = [];
                    
                    if (attendanceState is GetAttendanceByClassIdSuccess) {
                      attendanceList = attendanceState.attendanceList;
                    }
                    
                    final activities = _getActivitiesForDate(
                      attendanceList,
                      _selectedDate,
                    );
                    
                    if (activities.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No activity for this date',
                            style: TextStyle(
                              color: Color(0xff6D6B76),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        List<StaffClassEntity> staffClasses = [];
                        if (authState is GetStaffClassSuccess) {
                          staffClasses = authState.staffClasses;
                        }
                        final contacts = childState.contacts ?? [];
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...activities.map((activity) {
                              // پیدا کردن StaffClassEntity از staffId
                              StaffClassEntity? staffClass;
                              if (activity.attendance.staffId != null && 
                                  activity.attendance.staffId!.isNotEmpty) {
                                try {
                                  staffClass = staffClasses.firstWhere(
                                    (sc) => sc.staffId == activity.attendance.staffId,
                                  );
                                } catch (e) {
                                  // StaffClass not found
                                }
                              }
                              
                              // پیدا کردن ContactEntity از contactId
                              ContactEntity? contact;
                              if (staffClass?.contactId != null && 
                                  staffClass!.contactId!.isNotEmpty) {
                                contact = ContactUtils.getContactById(
                                  staffClass.contactId,
                                  contacts,
                                );
                              }
                              
                              // ساخت یک attendance entity موقت برای نمایش
                              final displayAttendance = AttendanceChildEntity(
                                id: activity.attendance.id,
                                checkInAt: activity.isCheckOut ? null : activity.attendance.checkInAt,
                                checkOutAt: activity.isCheckOut ? activity.attendance.checkOutAt : null,
                                childId: activity.attendance.childId,
                                classId: activity.attendance.classId,
                                staffId: activity.attendance.staffId,
                                checkInMethod: activity.isCheckOut ? null : activity.attendance.checkInMethod,
                                checkOutMethod: activity.isCheckOut ? activity.attendance.checkOutMethod : null,
                                notes: activity.attendance.notes,
                              );
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ActivitySectionWidget(
                                  attendance: displayAttendance,
                                  contact: contact,
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
