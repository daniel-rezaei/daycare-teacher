import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/contact_utils.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_status/services/local_absent_storage_service.dart';
import 'package:teacher_app/features/child_status/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_status/widgets/appbar_child.dart';
import 'package:teacher_app/features/child_status/widgets/bottom_navigation_bar_child.dart';
import 'package:teacher_app/features/child_status/widgets/check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/child_status_list_item.dart';
import 'package:teacher_app/features/child_status/widgets/more_details_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';

class ChildStatus extends StatefulWidget {
  const ChildStatus({super.key});

  @override
  State<ChildStatus> createState() => _ChildStatusState();
}

class _ChildStatusState extends State<ChildStatus> {
  String? classId;
  String? staffId;
  bool _hasRequestedData = false;
  bool _hasRequestedAttendance = false;
  Set<String> _locallyAbsentChildIds = {};

  @override
  void initState() {
    super.initState();
    _loadIds();
    _clearOldAbsentRecords();
  }

  Future<void> _clearOldAbsentRecords() async {
    await LocalAbsentStorageService.clearIfDateChanged();
  }

  Future<void> _loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString(AppConstants.classIdKey);
    final savedStaffId = prefs.getString(AppConstants.staffIdKey);
    
    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
        staffId = savedStaffId;
      });
      
      // بررسی اینکه آیا داده‌ها قبلاً لود شده‌اند
      final currentState = context.read<ChildBloc>().state;
      if (!_hasRequestedData) {
        _hasRequestedData = true;
        if (currentState.children == null) {
          context.read<ChildBloc>().add(const GetAllChildrenEvent());
        }
        if (currentState.contacts == null) {
          context.read<ChildBloc>().add(const GetAllContactsEvent());
        }
      }

      // دریافت attendance
      if (!_hasRequestedAttendance) {
        _hasRequestedAttendance = true;
        context.read<AttendanceBloc>().add(
          GetAttendanceByClassIdEvent(classId: savedClassId),
        );
      }

      // بارگذاری لیست غایبین محلی
      _loadLocallyAbsentChildren(savedClassId);
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



  void _handlePresentClick(String childId) {
    if (classId == null || staffId == null) {
      return;
    }

    // حذف از لیست غایبین محلی (اگر وجود داشته باشد)
    LocalAbsentStorageService.removeAbsent(classId!, childId).then((_) {
      _loadLocallyAbsentChildren(classId!);
    });

    final checkInAt = DateUtils.getCurrentDateTime();
    context.read<AttendanceBloc>().add(
      CreateAttendanceEvent(
        childId: childId,
        classId: classId!,
        checkInAt: checkInAt,
        staffId: staffId,
      ),
    );
  }

  void _handleAbsentClick(String childId) {
    if (classId == null) {
      return;
    }

    // ذخیره در لیست غایبین محلی (بدون ارسال درخواست به بک‌اند)
    LocalAbsentStorageService.markAbsent(classId!, childId).then((_) {
      if (mounted) {
        setState(() {
          _locallyAbsentChildIds.add(childId);
        });
      }
    });
  }

  void _handleCheckOutClick(
    String childId,
    String childName,
    List<AttendanceChildEntity> attendanceList,
  ) {
    if (classId == null) {
      return;
    }
    final attendance = ChildStatusHelper.getChildAttendance(
      childId,
      attendanceList,
      classId: classId,
    );
    if (attendance == null || attendance.id == null) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckOutWidget(
        childId: childId,
        childName: childName,
        attendanceId: attendance.id!,
        classId: classId!,
      ),
    );
  }

  void _handleMoreClick() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const MoreDetailsWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              children: [
                AppBarChild(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -4),
                          blurRadius: 16,
                          color: AppColors.shadowLight.withValues(alpha: .10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<AttendanceBloc, AttendanceState>(
                        builder: (context, attendanceState) {
                          return BlocBuilder<ChildBloc, ChildState>(
                            builder: (context, state) {
                              // بررسی لودینگ برای children و contacts
                              if (state.isLoadingChildren || state.isLoadingContacts) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }

                              // بررسی لودینگ برای attendance
                              if (attendanceState is GetAttendanceByClassIdLoading ||
                                  attendanceState is AttendanceInitial ||
                                  attendanceState is CreateAttendanceLoading) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }

                              final children = state.children;
                              final contacts = state.contacts;
                              List<AttendanceChildEntity> attendanceList = [];

                              if (attendanceState is GetAttendanceByClassIdSuccess) {
                                attendanceList = attendanceState.attendanceList;
                              }

                            if (children != null && contacts != null && classId != null) {
                              final childrenInClass = ChildStatusHelper.getChildrenInClass(
                                children,
                                contacts,
                              );
                              
                              final totalCount = childrenInClass.length;
                              final presentCount = childrenInClass
                                  .where((child) {
                                    final status = ChildStatusHelper.getChildStatusToday(
                                      childId: child.id ?? '',
                                      classId: classId!,
                                      attendanceList: attendanceList,
                                      locallyAbsentChildIds: _locallyAbsentChildIds,
                                    );
                                    return status == ChildAttendanceStatus.present;
                                  })
                                  .length;

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Children',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '$presentCount/$totalCount',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ListView.builder(
                                    itemCount: childrenInClass.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final child = childrenInClass[index];
                                      final contact = ContactUtils.getContactById(
                                        child.contactId,
                                        contacts,
                                      );
                                      final status = ChildStatusHelper.getChildStatusToday(
                                        childId: child.id ?? '',
                                        classId: classId!,
                                        attendanceList: attendanceList,
                                        locallyAbsentChildIds: _locallyAbsentChildIds,
                                      );

                                      // پیدا کردن attendance مربوط به این کودک برای امروز
                                      final attendance = ChildStatusHelper.getChildAttendance(
                                        child.id ?? '',
                                        attendanceList,
                                        classId: classId,
                                      );

                                      return ChildStatusListItem(
                                        child: child,
                                        contact: contact,
                                        status: status,
                                        attendance: attendance,
                                        onPresentTap: () => _handlePresentClick(child.id ?? ''),
                                        onAbsentTap: () => _handleAbsentClick(child.id ?? ''),
                                        onCheckOutTap: () => _handleCheckOutClick(
                                          child.id ?? '',
                                          ContactUtils.getContactName(contact),
                                          attendanceList,
                                        ),
                                        onMoreTap: _handleMoreClick,
                                      );
                                    },
                                  ),
                                ],
                              );
                            }

                            if (state.childrenError != null || 
                                state.contactsError != null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    state.childrenError ?? state.contactsError ?? 'خطا در دریافت اطلاعات',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          
        bottomNavigationBar: BottomNavigationBarChild(),
      );
    
  }
}
