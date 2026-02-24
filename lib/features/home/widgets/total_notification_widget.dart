import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/services/time_in_access_guard.dart';
import 'package:teacher_app/core/widgets/shimmer_placeholder.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child_management/screens/child_status_screen.dart';
import 'package:teacher_app/features/child_management/services/local_absent_storage_service.dart';
import 'package:teacher_app/features/child_management/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_management_bloc.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/info_card_widget.dart';
import 'package:teacher_app/features/home/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/home/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TotalNotificationWidget extends StatefulWidget {
  const TotalNotificationWidget({super.key});

  @override
  State<TotalNotificationWidget> createState() =>
      _TotalNotificationWidgetState();
}

class _TotalNotificationWidgetState extends State<TotalNotificationWidget> {
  String? classId;
  bool _hasRequestedChildren = false;
  bool _hasRequestedContacts = false;
  bool _hasRequestedAttendance = false;
  bool _hasRequestedNotifications = false;
  Set<String> _locallyAbsentChildIds = {};

  @override
  void initState() {
    super.initState();
    _loadClassId();
    _clearOldAbsentRecords();
  }

  Future<void> _clearOldAbsentRecords() async {
    await LocalAbsentStorageService.clearIfDateChanged();
  }

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString(AppConstants.classIdKey);
    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
      });
      // بررسی اینکه آیا داده‌ها قبلاً لود شده‌اند
      final currentState = context.read<HomeBloc>().state;

      if (!_hasRequestedChildren &&
          (currentState.children == null || currentState.isLoadingChildren)) {
        _hasRequestedChildren = true;
        context.read<HomeBloc>().add(const LoadChildrenEvent());
      }
      if (!_hasRequestedContacts &&
          (currentState.contacts == null || currentState.isLoadingContacts)) {
        _hasRequestedContacts = true;
        context.read<HomeBloc>().add(const LoadContactsEvent());
      }
      if (!_hasRequestedAttendance &&
          (currentState.attendanceList == null ||
              currentState.isLoadingAttendance)) {
        _hasRequestedAttendance = true;
        context.read<HomeBloc>().add(LoadAttendanceEvent(savedClassId));
      }

      // SINGLE SOURCE OF TRUTH: Ensure AttendanceBloc has attendance data for immediate updates
      // Check if AttendanceBloc needs to load data
      context.read<AttendanceBloc>().add(
        GetAttendanceByClassIdEvent(classId: savedClassId),
      );

      // بارگذاری لیست غایبین محلی
      _loadLocallyAbsentChildren(savedClassId);

      // دریافت notifications
      if (!_hasRequestedNotifications &&
          (currentState.notifications == null ||
              currentState.isLoadingNotifications)) {
        _hasRequestedNotifications = true;
        context.read<HomeBloc>().add(const LoadNotificationsEvent());
      }

      // دریافت session برای بررسی استارت کلاس (فقط اگر قبلاً لود نشده باشد)
      if (currentState.session == null && !currentState.isLoadingSession) {
        context.read<HomeBloc>().add(LoadSessionEvent(savedClassId));
      }
    }
  }

  Future<void> _loadLocallyAbsentChildren(String classId) async {
    final absentSet = await LocalAbsentStorageService.getAbsentToday(classId);
    if (mounted) {
      setState(() {
        _locallyAbsentChildIds = absentSet;
      });
    }
  }

  int _getTotalChildrenCount(
    List<ChildEntity>? children,
    List<ContactEntity>? contacts,
  ) {
    if (children == null || contacts == null) return 0;

    // فیلتر Contacts با Role="child" و استخراج contact_id های آن‌ها
    final validChildContactIds = contacts
        .where((contact) => contact.role == 'child')
        .map((contact) => contact.id)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    // فیلتر بچه‌هایی که contact_id آن‌ها در validChildContactIds موجود است
    // و primary_room_id آن‌ها برابر با class_id است
    final validChildren = children.where((child) {
      final isActive = child.status == 'active';
      final hasValidContactId =
          child.contactId != null && child.contactId!.isNotEmpty;
      final contactExists =
          hasValidContactId && validChildContactIds.contains(child.contactId);
      final isInClass =
          classId != null &&
          child.primaryRoomId != null &&
          child.primaryRoomId == classId;
      final shouldInclude =
          isActive && hasValidContactId && contactExists && isInClass;

      return shouldInclude;
    }).toList();

    return validChildren.length;
  }

  int _getPresentChildrenCount(
    List<ChildEntity>? children,
    List<ContactEntity>? contacts,
    List<AttendanceChildEntity>? attendanceList,
  ) {
    if (classId == null || children == null || contacts == null) {
      return 0;
    }

    final childrenInClass = ChildStatusHelper.getChildrenInClass(
      children,
      contacts,
      classId: classId,
    );

    // شمارش بچه‌هایی که وضعیت آن‌ها present است
    final presentCount = childrenInClass.where((child) {
      final status = ChildStatusHelper.getChildStatusToday(
        childId: child.id ?? '',
        classId: classId!,
        attendanceList: attendanceList ?? [],
        locallyAbsentChildIds: _locallyAbsentChildIds,
      );
      return status == ChildAttendanceStatus.present;
    }).length;

    return presentCount;
  }

  int _getTodayNotificationsCount(List<NotificationEntity>? notifications) {
    if (notifications == null) return 0;
    final now = DateTime.now();
    return notifications.where((notification) {
      if (notification.createdAt == null || notification.createdAt!.isEmpty) {
        return false;
      }
      return DateUtils.isSameDate(notification.createdAt!, now);
    }).length;
  }

  /// Check if class session is checked in (started but not ended)
  /// Returns true if class check-in is active, false otherwise
  bool _isClassCheckedIn(StaffClassSessionEntity? session) {
    if (session == null) return false;
    // Class is checked in if startAt exists and is not empty, and endAt is null or empty
    return session.startAt != null &&
        session.startAt!.isNotEmpty &&
        (session.endAt == null || session.endAt!.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, attendanceState) {
        // به‌روزرسانی لیست غایبین محلی وقتی attendance به‌روزرسانی می‌شود
        if (attendanceState is GetAttendanceByClassIdSuccess &&
            classId != null) {
          _loadLocallyAbsentChildren(classId!);
        }
      },
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, attendanceState) {
          return BlocBuilder<HomeBloc, HomeState>(
            builder: (context, homeState) {
              return BlocBuilder<ChildBloc, ChildState>(
                builder: (context, childState) {
                  String title = '0/0';
                  bool isLoading = false;

                  final children = homeState.children ?? childState.children;
                  final contacts = homeState.contacts ?? childState.contacts;
                  final isLoadingChildren =
                      homeState.isLoadingChildren ||
                      childState.isLoadingChildren;
                  final isLoadingContacts =
                      homeState.isLoadingContacts ||
                      childState.isLoadingContacts;
                  final childrenError =
                      homeState.childrenError ?? childState.childrenError;
                  final contactsError =
                      homeState.contactsError ?? childState.contactsError;

                  // SINGLE SOURCE OF TRUTH: Use AttendanceBloc state directly (same as Children List screen)
                  // This ensures immediate updates when attendance is created/updated
                  List<AttendanceChildEntity> attendanceList = [];
                  if (attendanceState is GetAttendanceByClassIdSuccess) {
                    attendanceList = attendanceState.attendanceList;
                  } else {
                    // Fallback to HomeBloc for initial load, but prefer AttendanceBloc
                    attendanceList = homeState.attendanceList ?? [];
                  }

                  final notifications = homeState.notifications ?? [];
                  final session = homeState.session;

                  // Loading state: check both AttendanceBloc and HomeBloc
                  final isLoadingAttendance =
                      attendanceState is GetAttendanceByClassIdLoading ||
                      homeState.isLoadingAttendance;
                  final isLoadingNotifications =
                      homeState.isLoadingNotifications;

                  // بررسی اینکه آیا هر دو داده موجود است
                  final hasBothData = children != null && contacts != null;
                  final hasError =
                      childrenError != null || contactsError != null;
                  final isCurrentlyLoading =
                      isLoadingChildren ||
                      isLoadingContacts ||
                      isLoadingAttendance ||
                      isLoadingNotifications;

                  // اگر در حال loading است
                  if (isCurrentlyLoading) {
                    isLoading = true;
                  }
                  // اگر هر دو داده موجود است
                  else if (hasBothData) {
                    final totalCount = _getTotalChildrenCount(
                      children,
                      contacts,
                    );
                    final presentCount = _getPresentChildrenCount(
                      children,
                      contacts,
                      attendanceList,
                    );
                    title = '$presentCount/$totalCount';
                    isLoading = false;
                  }
                  // اگر خطا رخ داده است
                  else if (hasError) {
                    // اگر داده‌های قبلی موجود است، از همان استفاده کن
                    if (hasBothData) {
                      final totalCount = _getTotalChildrenCount(
                        children,
                        contacts,
                      );
                      final presentCount = _getPresentChildrenCount(
                        children,
                        contacts,
                        attendanceList,
                      );
                      title = '$presentCount/$totalCount';
                      isLoading = false;
                    } else {
                      // اگر داده‌ای موجود نیست، loading را false کن و 0/0 نمایش بده
                      isLoading = false;
                      title = '0/0';
                    }
                  }
                  // در غیر این صورت (هنوز درخواست داده نشده یا در حال loading است)
                  else {
                    isLoading = true;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoCardWidget(
                        color: const Color(0XFFDEF4FF),
                        icon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Assets.images.subtract.svg(),
                        ),
                        title: isLoading
                            ? const ShimmerPlaceholder(
                                width: 28,
                                height: 20,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              )
                            : Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff444349),
                                ),
                              ),
                        dec: 'Total Children',
                        onTap: () {
                          // Get current states
                          final hasTimeIn =
                              TimeInAccessGuard.checkActiveTimeInFromContext(
                                context,
                              );
                          final isClassCheckedIn = _isClassCheckedIn(session);

                          // Validation priority for Student List access:
                          // 1) First check: If Time In is NOT done → Block and show "You must Time In first."
                          if (!hasTimeIn) {
                            CustomSnackbar.showWarning(context, 'You must Time In first.');
                            return;
                          }

                          // 2) Second check (only if Time In IS done):
                          //    If Class Check-In is NOT done → Block and show "You must Check-In the class before opening the Student List."
                          if (!isClassCheckedIn) {
                            CustomSnackbar.showWarning(context, 'You must Check-In the class before opening the Student List.');
                            return;
                          }

                          // 3) If both Time In AND Class Check-In are done → Allow access (continue to navigation)

                          // فقط در صورتی که داده‌ها لود شده باشند، اجازه رفتن به صفحه بعد را بده
                          final currentHomeState = context
                              .read<HomeBloc>()
                              .state;
                          final currentChildState = context
                              .read<ChildBloc>()
                              .state;
                          if ((currentHomeState.children != null ||
                                  currentChildState.children != null) &&
                              (currentHomeState.contacts != null ||
                                  currentChildState.contacts != null) &&
                              !currentHomeState.isLoadingChildren &&
                              !currentHomeState.isLoadingContacts &&
                              !currentChildState.isLoadingChildren &&
                              !currentChildState.isLoadingContacts) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (_) => getIt<ChildStatusModuleBloc>(),
                                  child: const ChildStatusScreen(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      InfoCardWidget(
                        color: const Color(0xffFEE5F2),
                        icon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Assets.images.vector.svg(),
                        ),
                        title: isLoadingNotifications
                            ? const ShimmerPlaceholder(
                                width: 28,
                                height: 20,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              )
                            : Text(
                                '${_getTodayNotificationsCount(notifications)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff444349),
                                ),
                              ),
                        dec: 'Notifications',
                        onTap: () {},
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
