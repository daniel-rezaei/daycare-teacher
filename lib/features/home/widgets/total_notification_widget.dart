import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_status/services/local_absent_storage_service.dart';
import 'package:teacher_app/features/child_status/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_status/child_status.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/info_card_widget.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TotalNotificationWidget extends StatefulWidget {
  const TotalNotificationWidget({super.key});

  @override
  State<TotalNotificationWidget> createState() => _TotalNotificationWidgetState();
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
    
    debugPrint('[TOTAL_NOTIFICATION_DEBUG] Loading classId: $savedClassId');
    
    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
      });
      if (!_hasRequestedChildren) {
        _hasRequestedChildren = true;
        debugPrint('[TOTAL_NOTIFICATION_DEBUG] Requesting LoadChildrenEvent');
        context.read<HomeBloc>().add(const LoadChildrenEvent());
      }
      if (!_hasRequestedContacts) {
        _hasRequestedContacts = true;
        debugPrint('[TOTAL_NOTIFICATION_DEBUG] Requesting LoadContactsEvent');
        context.read<HomeBloc>().add(const LoadContactsEvent());
      }
      if (!_hasRequestedAttendance) {
        _hasRequestedAttendance = true;
        debugPrint('[TOTAL_NOTIFICATION_DEBUG] Requesting LoadAttendanceEvent');
        context.read<HomeBloc>().add(LoadAttendanceEvent(savedClassId));
      }

      // بارگذاری لیست غایبین محلی
      _loadLocallyAbsentChildren(savedClassId);

      // دریافت notifications
      if (!_hasRequestedNotifications) {
        _hasRequestedNotifications = true;
        debugPrint('[TOTAL_NOTIFICATION_DEBUG] Requesting LoadNotificationsEvent');
        context.read<HomeBloc>().add(const LoadNotificationsEvent());
      }

      // دریافت session برای بررسی استارت کلاس
      context.read<HomeBloc>().add(LoadSessionEvent(savedClassId));
    } else {
      debugPrint('[TOTAL_NOTIFICATION_DEBUG] classId is null or empty');
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
    
    debugPrint('[TOTAL_NOTIFICATION_DEBUG] classId: $classId');
    debugPrint('[TOTAL_NOTIFICATION_DEBUG] Total children from API: ${children.length}');
    debugPrint('[TOTAL_NOTIFICATION_DEBUG] Total contacts with role=child: ${contacts.where((c) => c.role == 'child').length}');
    
    // فیلتر Contacts با Role="child" و استخراج contact_id های آن‌ها
    final validChildContactIds = contacts
        .where((contact) => contact.role == 'child')
        .map((contact) => contact.id)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    debugPrint('[TOTAL_NOTIFICATION_DEBUG] Valid child contact IDs: $validChildContactIds');

    // Debug: بررسی همه بچه‌ها
    for (var child in children) {
      debugPrint('[TOTAL_NOTIFICATION_DEBUG] Child: id=${child.id}, primaryRoomId=${child.primaryRoomId}, status=${child.status}, contactId=${child.contactId}');
    }

    // فیلتر بچه‌هایی که contact_id آن‌ها در validChildContactIds موجود است
    final validChildren = children.where((child) {
      final isActive = child.status == 'active';
      final hasValidContactId = child.contactId != null && child.contactId!.isNotEmpty;
      final contactExists = hasValidContactId && validChildContactIds.contains(child.contactId);
      final shouldInclude = isActive && hasValidContactId && contactExists;
      
      debugPrint('[TOTAL_NOTIFICATION_DEBUG] Child ${child.id}: primaryRoomId=${child.primaryRoomId}, isActive=$isActive, hasValidContactId=$hasValidContactId, contactExists=$contactExists, shouldInclude=$shouldInclude');
      
      return shouldInclude;
    }).toList();

    debugPrint('[TOTAL_NOTIFICATION_DEBUG] Valid children count: ${validChildren.length}');

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
    );

    // شمارش بچه‌هایی که وضعیت آن‌ها present است
    final presentCount = childrenInClass
        .where((child) {
          final status = ChildStatusHelper.getChildStatusToday(
            childId: child.id ?? '',
            classId: classId!,
            attendanceList: attendanceList ?? [],
            locallyAbsentChildIds: _locallyAbsentChildIds,
          );
          return status == ChildAttendanceStatus.present;
        })
        .length;

    return presentCount;
  }

  int _getTodayNotificationsCount(List<NotificationEntity>? notifications) {
    if (notifications == null) return 0;
    final now = DateTime.now();
    return notifications
        .where((notification) {
          if (notification.createdAt == null || notification.createdAt!.isEmpty) {
            return false;
          }
          return DateUtils.isSameDate(notification.createdAt!, now);
        })
        .length;
  }

  /// بررسی اینکه آیا کلاس استارت شده است یا نه
  bool _isClassStarted(StaffClassSessionEntity? session) {
    if (session == null) return false;
    // اگر start_at وجود دارد و end_at null است، یعنی check-in شده
    return session.startAt != null &&
        session.startAt!.isNotEmpty &&
        (session.endAt == null || session.endAt!.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, attendanceState) {
        // به‌روزرسانی لیست غایبین محلی وقتی attendance به‌روزرسانی می‌شود
        if (attendanceState is GetAttendanceByClassIdSuccess && classId != null) {
          _loadLocallyAbsentChildren(classId!);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          return BlocBuilder<ChildBloc, ChildState>(
            builder: (context, childState) {
              String title = '0/0';
              bool isLoading = false;

              final children = homeState.children ?? childState.children;
              final contacts = homeState.contacts ?? childState.contacts;
              final isLoadingChildren = homeState.isLoadingChildren || childState.isLoadingChildren;
              final isLoadingContacts = homeState.isLoadingContacts || childState.isLoadingContacts;
              final childrenError = homeState.childrenError ?? childState.childrenError;
              final contactsError = homeState.contactsError ?? childState.contactsError;

              final attendanceList = homeState.attendanceList ?? [];
              final notifications = homeState.notifications ?? [];
              final session = homeState.session;
              final isClassStarted = _isClassStarted(session);

              final isLoadingAttendance = homeState.isLoadingAttendance;
              final isLoadingNotifications = homeState.isLoadingNotifications;

              debugPrint('[TOTAL_NOTIFICATION_DEBUG] State: children=${children?.length ?? 'null'}, contacts=${contacts?.length ?? 'null'}, attendance=${attendanceList.length}, isLoadingChildren=$isLoadingChildren, isLoadingContacts=$isLoadingContacts, isLoadingAttendance=$isLoadingAttendance, childrenError=$childrenError, contactsError=$contactsError');

              // بررسی اینکه آیا هر دو داده موجود است
              final hasBothData = children != null && contacts != null;
              final hasError = childrenError != null || contactsError != null;
              final isCurrentlyLoading = isLoadingChildren || isLoadingContacts || isLoadingAttendance || isLoadingNotifications;
              
              // اگر در حال loading است
              if (isCurrentlyLoading) {
                isLoading = true;
              } 
              // اگر هر دو داده موجود است
              else if (hasBothData) {
                final totalCount = _getTotalChildrenCount(children, contacts);
                final presentCount = _getPresentChildrenCount(children, contacts, attendanceList);
                title = '$presentCount/$totalCount';
                isLoading = false;
              } 
              // اگر خطا رخ داده است
              else if (hasError) {
                // اگر داده‌های قبلی موجود است، از همان استفاده کن
                if (hasBothData) {
                  final totalCount = _getTotalChildrenCount(children, contacts);
                  final presentCount = _getPresentChildrenCount(children, contacts, attendanceList);
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CupertinoActivityIndicator(radius: 10),
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
                      // بررسی اینکه آیا کلاس استارت شده است
                      if (!isClassStarted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لطفاً ابتدا کلاس را استارت کنید'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // فقط در صورتی که داده‌ها لود شده باشند، اجازه رفتن به صفحه بعد را بده
                      final currentHomeState = context.read<HomeBloc>().state;
                      final currentChildState = context.read<ChildBloc>().state;
                      if ((currentHomeState.children != null || currentChildState.children != null) && 
                          (currentHomeState.contacts != null || currentChildState.contacts != null) &&
                          !currentHomeState.isLoadingChildren &&
                          !currentHomeState.isLoadingContacts &&
                          !currentChildState.isLoadingChildren &&
                          !currentChildState.isLoadingContacts) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChildStatus()),
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CupertinoActivityIndicator(radius: 10),
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
      ),
    );
  }
}
