import 'package:flutter/cupertino.dart';
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
import 'package:teacher_app/features/child_emergency_contact/domain/entity/child_emergency_contact_entity.dart';
import 'package:teacher_app/features/child_emergency_contact/presentation/bloc/child_emergency_contact_bloc.dart';
import 'package:teacher_app/features/child_guardian/domain/entity/child_guardian_entity.dart';
import 'package:teacher_app/features/child_guardian/presentation/bloc/child_guardian_bloc.dart';
import 'package:teacher_app/features/child_profile/widgets/activity_section_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/day_strip_widget.dart';
import 'package:teacher_app/features/pickup_authorization/domain/entity/pickup_authorization_entity.dart';
import 'package:teacher_app/features/pickup_authorization/presentation/bloc/pickup_authorization_bloc.dart';
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
  String?
  _lastRequestedDate; // Track last requested date to prevent duplicate requests

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
        final foundChild = childState.children!.firstWhere(
          (c) => c.contactId == widget.childId,
        );
        if (mounted) {
          setState(() {
            _actualChildId = foundChild.id;
          });
          _loadAttendanceForDate(_selectedDate);
        }
      }
    }
  }

  /// Load attendance for the selected date
  /// Always requests fresh data when date changes
  void _loadAttendanceForDate(DateTime date) {
    if (_classId == null || _actualChildId == null) return;

    // Format date as YYYY-MM-DD for comparison
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Only request if date changed (prevent duplicate requests)
    if (_lastRequestedDate == dateString) {
      return;
    }
    _lastRequestedDate = dateString;
    // Request attendance
    context.read<AttendanceBloc>().add(
      GetAttendanceByClassIdEvent(classId: _classId!, childId: _actualChildId),
    );

    // Load staff classes if not already loaded
    final authState = context.read<AuthBloc>().state;
    if (authState is! GetStaffClassSuccess && _classId != null) {
      context.read<AuthBloc>().add(GetStaffClassEvent(classId: _classId!));
    }

    // Load pickup-related data for checkout person resolution
    _loadPickupData();
  }

  /// Load pickup-related data (authorization, emergency contacts, guardians)
  void _loadPickupData() {
    if (_actualChildId == null) return;
    // Load pickup authorizations
    context.read<PickupAuthorizationBloc>().add(
      GetPickupAuthorizationByChildIdEvent(childId: _actualChildId!),
    );

    // Load emergency contacts
    context.read<ChildEmergencyContactBloc>().add(
      const GetAllChildEmergencyContactsEvent(),
    );

    // Load guardians
    context.read<ChildGuardianBloc>().add(
      GetChildGuardianByChildIdEvent(childId: _actualChildId!),
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _lastRequestedDate = null; // Reset to force new request
    });
    // Always trigger new API call on date change
    _loadAttendanceForDate(date);
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
          activities.add(
            _ActivityItem(
              attendance: attendance,
              isCheckOut: false,
              time: attendance.checkInAt!,
            ),
          );
        }
      }

      // بررسی check_out_at
      if (attendance.checkOutAt != null && attendance.checkOutAt!.isNotEmpty) {
        if (DateUtils.isSameDate(attendance.checkOutAt!, date)) {
          activities.add(
            _ActivityItem(
              attendance: attendance,
              isCheckOut: true,
              time: attendance.checkOutAt!,
            ),
          );
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

  /// Find teacher contact for CHECK-IN activities
  ContactEntity? _findTeacher(
    AttendanceChildEntity attendance,
    List<StaffClassEntity> staffClasses,
    List<ContactEntity> contacts,
  ) {
    if (attendance.staffId == null || attendance.staffId!.isEmpty) {
      return null;
    }
    final staffClass = staffClasses.firstWhere(
      (sc) => sc.staffId == attendance.staffId,
    );

    if (staffClass.contactId != null && staffClass.contactId!.isNotEmpty) {
      final contact = ContactUtils.getContactById(
        staffClass.contactId,
        contacts,
      );
      if (contact != null) {
        return contact;
      }
    }

    return null;
  }

  /// Find pickup person for CHECK-OUT activities
  /// Priority: 1. Pickup Authorization, 2. Emergency Contact, 3. Guardian
  /// Note: checkout_pickup_contact_id would be in raw API response but not available in entity
  ContactEntity? _findPickupPerson(
    AttendanceChildEntity attendance,
    List<PickupAuthorizationEntity> pickupAuthorizations,
    List<ChildEmergencyContactEntity> emergencyContacts,
    List<ChildGuardianEntity> guardians,
    List<ContactEntity> contacts,
  ) {
    // Priority 1: Pickup Authorization (any authorized pickup for the child)
    if (attendance.childId != null && attendance.childId!.isNotEmpty) {
      final pickupAuth = pickupAuthorizations.firstWhere(
        (pa) => pa.childId == attendance.childId,
      );

      if (pickupAuth.authorizedContactId != null &&
          pickupAuth.authorizedContactId!.isNotEmpty) {
        final contact = ContactUtils.getContactById(
          pickupAuth.authorizedContactId,
          contacts,
        );
        if (contact != null) {
          return contact;
        }
      }
    }

    // Priority 2: Emergency Contact
    if (attendance.childId != null && attendance.childId!.isNotEmpty) {
      final emergencyContact = emergencyContacts.firstWhere(
        (ec) =>
            ec.childId == attendance.childId &&
            (ec.isActive == true || ec.isActive == null),
      );

      if (emergencyContact.contactId != null &&
          emergencyContact.contactId!.isNotEmpty) {
        final contact = ContactUtils.getContactById(
          emergencyContact.contactId,
          contacts,
        );
        if (contact != null) {
          return contact;
        }
      }
    }

    // Priority 3: Guardian (fallback)
    if (attendance.childId != null && attendance.childId!.isNotEmpty) {
      // Find first active guardian for the child
      final guardian = guardians.firstWhere(
        (g) =>
            g.childId == attendance.childId &&
            (g.pickupAuthorized == true || g.pickupAuthorized == null),
      );

      if (guardian.contactId != null && guardian.contactId!.isNotEmpty) {
        final contact = ContactUtils.getContactById(
          guardian.contactId,
          contacts,
        );
        if (contact != null) {
          return contact;
        }
      }
    }
    return null;
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
                _loadAttendanceForDate(_selectedDate);
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
            children: [
              DayStripWidget(onDateSelected: _onDateSelected),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffFFFFFF).withValues(alpha: .8),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
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
                      // Show loading indicator while requesting
                      if (attendanceState is GetAttendanceByClassIdLoading) {
                        return Center(child: CupertinoActivityIndicator());
                      }

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
                          return BlocBuilder<
                            PickupAuthorizationBloc,
                            PickupAuthorizationState
                          >(
                            builder: (context, pickupState) {
                              return BlocBuilder<
                                ChildEmergencyContactBloc,
                                ChildEmergencyContactState
                              >(
                                builder: (context, emergencyState) {
                                  return BlocBuilder<
                                    ChildGuardianBloc,
                                    ChildGuardianState
                                  >(
                                    builder: (context, guardianState) {
                                      List<StaffClassEntity> staffClasses = [];
                                      if (authState is GetStaffClassSuccess) {
                                        staffClasses = authState.staffClasses;
                                      }
                                      final contacts =
                                          childState.contacts ?? [];

                                      // Get pickup authorizations
                                      List<PickupAuthorizationEntity>
                                      pickupAuthorizations = [];
                                      if (pickupState
                                          is GetPickupAuthorizationByChildIdSuccess) {
                                        pickupAuthorizations =
                                            pickupState.pickupAuthorizationList;
                                      }

                                      // Get emergency contacts
                                      List<ChildEmergencyContactEntity>
                                      emergencyContacts = [];
                                      if (emergencyState
                                          is GetAllChildEmergencyContactsSuccess) {
                                        emergencyContacts =
                                            emergencyState.emergencyContactList;
                                      }

                                      // Get guardians
                                      List<ChildGuardianEntity> guardians = [];
                                      if (guardianState
                                          is GetChildGuardianByChildIdSuccess) {
                                        guardians = guardianState.guardianList;
                                      }

                                      return SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...activities.map((activity) {
                                              ContactEntity? contact;

                                              if (activity.isCheckOut) {
                                                // CHECK-OUT: Find pickup person
                                                contact = _findPickupPerson(
                                                  activity.attendance,
                                                  pickupAuthorizations,
                                                  emergencyContacts,
                                                  guardians,
                                                  contacts,
                                                );
                                              } else {
                                                // CHECK-IN: Find teacher
                                                contact = _findTeacher(
                                                  activity.attendance,
                                                  staffClasses,
                                                  contacts,
                                                );
                                              }

                                              // ساخت یک attendance entity موقت برای نمایش
                                              final displayAttendance =
                                                  AttendanceChildEntity(
                                                    id: activity.attendance.id,
                                                    checkInAt:
                                                        activity.isCheckOut
                                                        ? null
                                                        : activity
                                                              .attendance
                                                              .checkInAt,
                                                    checkOutAt:
                                                        activity.isCheckOut
                                                        ? activity
                                                              .attendance
                                                              .checkOutAt
                                                        : null,
                                                    childId: activity
                                                        .attendance
                                                        .childId,
                                                    classId: activity
                                                        .attendance
                                                        .classId,
                                                    staffId: activity
                                                        .attendance
                                                        .staffId,
                                                    checkInMethod:
                                                        activity.isCheckOut
                                                        ? null
                                                        : activity
                                                              .attendance
                                                              .checkInMethod,
                                                    checkOutMethod:
                                                        activity.isCheckOut
                                                        ? activity
                                                              .attendance
                                                              .checkOutMethod
                                                        : null,
                                                    notes: activity
                                                        .attendance
                                                        .notes,
                                                  );

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: ActivitySectionWidget(
                                                  attendance: displayAttendance,
                                                  contact: contact,
                                                  isCheckOut:
                                                      activity.isCheckOut,
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
