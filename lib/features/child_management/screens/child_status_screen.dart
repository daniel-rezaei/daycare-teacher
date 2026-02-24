import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/utils/contact_utils.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_management_bloc.dart';
import 'package:teacher_app/features/child_management/services/local_absent_storage_service.dart';
import 'package:teacher_app/features/child_management/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_management/widgets/appbar_child.dart';
import 'package:teacher_app/features/child_management/widgets/bottom_navigation_bar_child.dart';
import 'package:teacher_app/features/child_management/widgets/check_out_widget.dart';
import 'package:teacher_app/features/child_management/widgets/child_status_list_item.dart';
import 'package:teacher_app/features/child_management/widgets/more_details_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/class_transfer_request_bloc.dart';

class ChildStatusScreen extends StatefulWidget {
  const ChildStatusScreen({super.key});

  @override
  State<ChildStatusScreen> createState() => _ChildStatusScreenState();
}

class _ChildStatusScreenState extends State<ChildStatusScreen> {
  String? classId;
  String? staffId;

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
      context.read<ChildStatusModuleBloc>().add(
            LoadChildrenStatusEvent(classId: savedClassId),
          );
    }
  }

  void _refreshChildrenStatus() {
    if (classId != null) {
      context.read<ChildStatusModuleBloc>().add(
            LoadChildrenStatusEvent(classId: classId!),
          );
    }
  }

  void _handlePresentClick(String childId) {
    if (classId == null || staffId == null) return;
    LocalAbsentStorageService.removeAbsent(classId!, childId).then((_) {
      _refreshChildrenStatus();
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
    if (classId == null) return;
    LocalAbsentStorageService.markAbsent(classId!, childId).then((_) {
      _refreshChildrenStatus();
    });
  }

  void _handleCheckOutClick(
    String childId,
    String childName,
    List<AttendanceChildEntity> attendanceList,
  ) {
    if (classId == null) return;
    final attendance = ChildStatusHelper.getChildAttendance(
      childId,
      attendanceList,
      classId: classId,
    );
    if (attendance == null || attendance.id == null) return;

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
    ChildEntity? childEntity,
  ) {
    if (classId.isEmpty) return;
    final firstName = contact?.firstName ?? '';
    final lastName = contact?.lastName ?? '';
    final attendanceId = attendance?.id;
    final childCurrentClassId = childEntity?.primaryRoomId ?? classId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => MoreDetailsWidget(
        childId: childId,
        classId: classId,
        childCurrentClassId: childCurrentClassId,
        childImage: childPhoto,
        childFirstName: firstName,
        childLastName: lastName,
        childAttendanceStatus: status,
        attendanceId: attendanceId,
      ),
    );
  }

  void _handleAcceptTransfer(String requestId) {
    context.read<ClassTransferRequestBloc>().add(
      UpdateTransferRequestStatusEvent(
        requestId: requestId,
        status: 'accepted',
      ),
    );
  }

  void _handleDeclineTransfer(String requestId) {
    context.read<ClassTransferRequestBloc>().add(
      UpdateTransferRequestStatusEvent(
        requestId: requestId,
        status: 'declined',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is CreateAttendanceSuccess ||
                state is UpdateAttendanceSuccess) {
              _refreshChildrenStatus();
            }
          },
        ),
        BlocListener<ClassTransferRequestBloc, ClassTransferRequestState>(
          listener: (context, state) {
            if (state is GetTransferRequestsByClassIdSuccess ||
                state is CreateTransferRequestSuccess ||
                state is UpdateTransferRequestStatusSuccess) {
              _refreshChildrenStatus();
            }
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            BackgroundWidget(),
            SafeArea(
              child: Column(
                children: [
                  AppBarChildWidget(),
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
                        child: BlocBuilder<ChildStatusModuleBloc,
                            ChildStatusModuleState>(
                          builder: (context, moduleState) {
                            if (moduleState is LoadChildrenStatusLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            }
                            if (moduleState is LoadChildrenStatusFailure) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    moduleState.message,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (moduleState is! LoadChildrenStatusSuccess ||
                                classId == null) {
                              return const SizedBox.shrink();
                            }

                            final aggregate = moduleState.aggregate;
                            final children = aggregate.children;
                            final contacts = aggregate.contacts;
                            final attendanceList = aggregate.attendanceList;
                            final locallyAbsentChildIds =
                                aggregate.locallyAbsentChildIds;
                            final transferRequestsByStudentId = {
                              for (var r in aggregate.transferRequests)
                                if (r.studentId != null) r.studentId!: r,
                            };

                            final childrenInClass =
                                ChildStatusHelper.getChildrenInClass(
                              children,
                              contacts,
                              classId: classId,
                            );

                            final totalCount = childrenInClass.length;
                            final presentCount = childrenInClass.where((child) {
                              final status =
                                  ChildStatusHelper.getChildStatusToday(
                                childId: child.id ?? '',
                                classId: classId!,
                                attendanceList: attendanceList,
                                locallyAbsentChildIds: locallyAbsentChildIds,
                              );
                              return status == ChildAttendanceStatus.present;
                            }).length;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final child = childrenInClass[index];
                                    final contact = ContactUtils.getContactById(
                                      child.contactId,
                                      contacts,
                                    );

                                    final status =
                                        ChildStatusHelper.getChildStatusToday(
                                      childId: child.id ?? '',
                                      classId: classId!,
                                      attendanceList: attendanceList,
                                      locallyAbsentChildIds:
                                          locallyAbsentChildIds,
                                    );

                                    final attendance =
                                        ChildStatusHelper.getChildAttendance(
                                      child.id ?? '',
                                      attendanceList,
                                      classId: classId,
                                    );

                                    final transferRequest = child.id != null
                                        ? transferRequestsByStudentId[
                                            child.id]
                                        : null;

                                    return ChildStatusListItemWidget(
                                      child: child,
                                      contact: contact,
                                      status: status,
                                      attendance: attendance,
                                      currentClassId: classId!,
                                      transferRequest: transferRequest,
                                      onPresentTap: () =>
                                          _handlePresentClick(child.id ?? ''),
                                      onAbsentTap: () =>
                                          _handleAbsentClick(child.id ?? ''),
                                      onCheckOutTap: () => _handleCheckOutClick(
                                        child.id ?? '',
                                        ContactUtils.getContactName(contact),
                                        attendanceList,
                                      ),
                                      onMoreTap: (
                                        childId,
                                        childName,
                                        childPhoto,
                                      ) => _handleMoreClick(
                                        child.id ?? '',
                                        ContactUtils.getContactName(contact),
                                        child.photo,
                                        classId!,
                                        status,
                                        attendance,
                                        contact,
                                        child,
                                      ),
                                      onAcceptTransfer:
                                          transferRequest?.id != null
                                              ? () => _handleAcceptTransfer(
                                                    transferRequest!.id!,
                                                  )
                                              : null,
                                      onDeclineTransfer:
                                          transferRequest?.id != null
                                              ? () => _handleDeclineTransfer(
                                                    transferRequest!.id!,
                                                  )
                                              : null,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBarChildWidget(),
      ),
    );
  }
}
