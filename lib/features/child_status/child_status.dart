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
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

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
  List<AttendanceChildEntity> _lastAttendanceList = []; // حفظ آخرین لیست attendance
  
  // Helper method برای مقایسه دو لیست attendance
  bool _listsAreEqual(List<AttendanceChildEntity> list1, List<AttendanceChildEntity> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
      if (list1[i].checkOutAt != list2[i].checkOutAt) return false;
    }
    return true;
  }

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

  void _handleMoreClick(
    String childId,
    String childName,
    String? childPhoto,
    String classId,
    ChildAttendanceStatus status,
    AttendanceChildEntity? attendance,
    ContactEntity? contact,
  ) {
    if (classId.isEmpty) {
      return;
    }

    final firstName = contact?.firstName ?? '';
    final lastName = contact?.lastName ?? '';
    final attendanceId = attendance?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => MoreDetailsWidget(
        childId: childId,
        classId: classId,
        childImage: childPhoto,
        childFirstName: firstName,
        childLastName: lastName,
        childAttendanceStatus: status,
        attendanceId: attendanceId,
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
                        buildWhen: (previous, current) {
                          // فقط rebuild کن اگر state واقعاً تغییر کرده باشد
                          return true;
                        },
                        builder: (context, attendanceState) {
                          // حفظ آخرین لیست موفق attendance
                          // همیشه سعی می‌کنیم آخرین GetAttendanceByClassIdSuccess را از bloc بگیریم
                          final bloc = context.read<AttendanceBloc>();
                          
                          // اگر state فعلی GetAttendanceByClassIdSuccess است، لیست را به‌روز می‌کنیم
                          if (bloc.state is GetAttendanceByClassIdSuccess) {
                            final currentState = bloc.state as GetAttendanceByClassIdSuccess;
                            final newListLength = currentState.attendanceList.length;
                            final oldListLength = _lastAttendanceList.length;
                            
                            // فقط اگر لیست تغییر کرده باشد، به‌روز می‌کنیم
                            if (newListLength != oldListLength || 
                                !_listsAreEqual(_lastAttendanceList, currentState.attendanceList)) {
                              debugPrint('[CHILD_STATUS] 📋 Updating _lastAttendanceList: $oldListLength -> $newListLength items');
                              _lastAttendanceList = List.from(currentState.attendanceList); // کپی کردن لیست
                              debugPrint('[CHILD_STATUS] 📋 _lastAttendanceList updated. First 3 IDs: ${_lastAttendanceList.take(3).map((a) => '${a.id}(${a.childId})').join(', ')}');
                            } else {
                              debugPrint('[CHILD_STATUS] 📋 _lastAttendanceList unchanged: $newListLength items');
                            }
                          } else {
                            debugPrint('[CHILD_STATUS] 📋 Current bloc state is not GetAttendanceByClassIdSuccess: ${bloc.state.runtimeType}');
                            debugPrint('[CHILD_STATUS] 📋 Keeping _lastAttendanceList: ${_lastAttendanceList.length} items');
                          }
                          
                          debugPrint('[CHILD_STATUS] 🔄 BlocBuilder rebuild - attendanceState: ${attendanceState.runtimeType}, _lastAttendanceList.length: ${_lastAttendanceList.length}');
                          
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

                              // بررسی لودینگ برای attendance - فقط برای بارگذاری اولیه
                              // اگر در حال loading هستیم و لیست قبلی خالی است، loading نشان می‌دهیم
                              if (attendanceState is GetAttendanceByClassIdLoading && _lastAttendanceList.isEmpty) {
                                debugPrint('[CHILD_STATUS] ⏳ Showing loading (initial load)');
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }
                              
                              // اگر در حالت initial هستیم و لیست خالی است، loading نشان می‌دهیم
                              if (attendanceState is AttendanceInitial && _lastAttendanceList.isEmpty) {
                                debugPrint('[CHILD_STATUS] ⏳ Showing loading (initial state)');
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CupertinoActivityIndicator(),
                                  ),
                                );
                              }
                              
                              // اگر در حال loading هستیم اما لیست قبلی وجود دارد، از لیست قبلی استفاده می‌کنیم
                              if (attendanceState is GetAttendanceByClassIdLoading && _lastAttendanceList.isNotEmpty) {
                                debugPrint('[CHILD_STATUS] ⚠️ Loading but using previous list: ${_lastAttendanceList.length} items');
                              }

                              final children = state.children;
                              final contacts = state.contacts;
                              List<AttendanceChildEntity> attendanceList = [];

                              // استفاده از آخرین لیست موفق یا لیست فعلی
                              if (attendanceState is GetAttendanceByClassIdSuccess) {
                                attendanceList = attendanceState.attendanceList;
                                debugPrint('[CHILD_STATUS] ✅ Using GetAttendanceByClassIdSuccess list: ${attendanceList.length} items');
                              } else if (_lastAttendanceList.isNotEmpty) {
                                // اگر در حالت loading هستیم، از آخرین لیست موفق استفاده می‌کنیم
                                attendanceList = _lastAttendanceList;
                                debugPrint('[CHILD_STATUS] ⚠️ Using _lastAttendanceList (state: ${attendanceState.runtimeType}): ${attendanceList.length} items');
                              } else {
                                debugPrint('[CHILD_STATUS] ❌ No attendance list available! State: ${attendanceState.runtimeType}, _lastAttendanceList: ${_lastAttendanceList.length}');
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
                                      
                                      debugPrint('[CHILD_STATUS] 👶 Building item for child: ${child.id}, attendanceList.length: ${attendanceList.length}');
                                      
                                      final status = ChildStatusHelper.getChildStatusToday(
                                        childId: child.id ?? '',
                                        classId: classId!,
                                        attendanceList: attendanceList,
                                        locallyAbsentChildIds: _locallyAbsentChildIds,
                                      );
                                      
                                      debugPrint('[CHILD_STATUS] 👶 Child ${child.id} status: $status');

                                      // پیدا کردن attendance مربوط به این کودک برای امروز
                                      final attendance = ChildStatusHelper.getChildAttendance(
                                        child.id ?? '',
                                        attendanceList,
                                        classId: classId,
                                      );
                                      
                                      if (attendance != null) {
                                        debugPrint('[CHILD_STATUS] 👶 Child ${child.id} attendance: id=${attendance.id}, checkIn=${attendance.checkInAt}, checkOut=${attendance.checkOutAt}');
                                      } else {
                                        debugPrint('[CHILD_STATUS] 👶 Child ${child.id} attendance: null');
                                      }

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
                                        onMoreTap: (childId, childName, childPhoto) => _handleMoreClick(
                                          child.id ?? '',
                                          ContactUtils.getContactName(contact),
                                          child.photo,
                                          classId!,
                                          status,
                                          attendance,
                                          contact,
                                        ),
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
