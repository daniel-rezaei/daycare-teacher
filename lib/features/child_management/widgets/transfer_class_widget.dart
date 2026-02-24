import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/child_management/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/child_management/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/class_transfer_request_bloc.dart';

class TransferClassWidget extends StatefulWidget {
  final String studentId;
  final String currentClassId;

  const TransferClassWidget({
    super.key,
    required this.studentId,
    required this.currentClassId,
  });

  @override
  State<TransferClassWidget> createState() => _TransferClassWidgetState();
}

class _TransferClassWidgetState extends State<TransferClassWidget> {
  String? selectedClassId;
  bool _isSubmitting = false;
  ClassTransferRequestEntity? _existingRequest;
  String? _staffId;

  @override
  void initState() {
    super.initState();
    selectedClassId = widget.currentClassId;
    _loadStaffId();
    // Fetch classes if not already loaded
    final homeState = context.read<HomeBloc>().state;
    if (homeState.classRooms == null || homeState.classRooms!.isEmpty) {
      context.read<HomeBloc>().add(const LoadClassRoomsEvent());
    }
    // Check for existing pending transfer request
    context.read<ClassTransferRequestBloc>().add(
          GetTransferRequestByStudentIdEvent(studentId: widget.studentId),
        );
  }

  Future<void> _loadStaffId() async {
    final prefs = await SharedPreferences.getInstance();
    final staffId = prefs.getString(AppConstants.staffIdKey);
    if (mounted && staffId != null && staffId.isNotEmpty) {
      setState(() {
        _staffId = staffId;
      });
    }
  }

  bool get _canSave {
    return selectedClassId != null &&
        selectedClassId != widget.currentClassId &&
        !_isSubmitting &&
        _existingRequest == null; // Can't save if there's already a pending request
  }

  void _handleSave() {
    if (!_canSave || selectedClassId == null) return;

    // Prevent duplicate requests
    if (_existingRequest != null && _existingRequest!.status == 'pending') {
      CustomSnackbar.showWarning(context, 'A transfer request is currently under review');
      return;
    }

    // Check if staffId is available
    if (_staffId == null || _staffId!.isEmpty) {
      CustomSnackbar.showError(context, 'Error: Staff ID not found');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    context.read<ClassTransferRequestBloc>().add(
          CreateTransferRequestEvent(
            childId: widget.studentId,
            fromClassId: widget.currentClassId,
            toClassId: selectedClassId!,
            requestedByStaffId: _staffId!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClassTransferRequestBloc, ClassTransferRequestState>(
      listener: (context, state) {
        if (state is GetTransferRequestByStudentIdSuccess) {
          setState(() {
            _existingRequest = state.request;
          });
          // If there's a pending request, show a message
          if (state.request != null && state.request!.status == 'pending') {
            CustomSnackbar.showWarning(context, 'A transfer request is currently under review');
          }
        } else if (state is CreateTransferRequestSuccess) {
          setState(() {
            _isSubmitting = false;
            _existingRequest = state.request;
          });
          // Refresh transfer requests list in the parent screen
          // Use the from_class_id (current class) to refresh
          context.read<ClassTransferRequestBloc>().add(
                GetTransferRequestsByClassIdEvent(classId: widget.currentClassId),
              );
          Navigator.pop(context);
          CustomSnackbar.showSuccess(context, 'Transfer request submitted successfully');
        } else if (state is CreateTransferRequestFailure) {
          setState(() {
            _isSubmitting = false;
          });
          CustomSnackbar.showError(context, state.message);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          final classes = homeState.classRooms ?? [];
          final isLoading = homeState.isLoadingClassRooms;

          return ModalBottomSheetWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderCheckOutWidget(isIcon: false, title: 'Transfer Class'),
                const Divider(color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transfer Class',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CupertinoActivityIndicator(),
                          ),
                        )
                      else if (classes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No classes found',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else ...[
                        if (_existingRequest != null &&
                            _existingRequest!.status == 'pending')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'A transfer request is currently under review',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        TransferClassListWidget(
                          rooms: classes,
                          selectedClassId: selectedClassId,
                          currentClassId: widget.currentClassId,
                          onClassSelected: (value) {
                            setState(() {
                              selectedClassId = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 32),
                      ButtonWidget(
                        isEnabled: _canSave,
                        onTap: _canSave ? _handleSave : null,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CupertinoActivityIndicator(
                                  radius: 10,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class TransferClassListWidget extends StatelessWidget {
  final List<ClassRoomEntity> rooms;
  final String? selectedClassId;
  final String? currentClassId; // Optional - only used when transferring
  final ValueChanged<String> onClassSelected;

  const TransferClassListWidget({
    super.key,
    required this.rooms,
    required this.selectedClassId,
    this.currentClassId,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔹 Empty state
    if (rooms.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No classes found',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: rooms.map((room) {
        final roomId = room.id;
        final roomName = room.roomName ?? 'Unknown';
        final isSelected = roomId != null && roomId == selectedClassId;
        final isCurrentClass = roomId != null && roomId == currentClassId;

        return _ClassItem(
          id: roomId,
          name: roomName,
          isSelected: isSelected,
          isCurrentClass: currentClassId != null && isCurrentClass,
          onTap: roomId == null ? null : () => onClassSelected(roomId),
        );
      }).toList(),
    );
  }
}

class _ClassItem extends StatelessWidget {
  final String? id;
  final String name;
  final bool isSelected;
  final bool isCurrentClass;
  final VoidCallback? onTap;

  const _ClassItem({
    required this.id,
    required this.name,
    required this.isSelected,
    required this.isCurrentClass,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isCurrentClass
                    ? AppColors.backgroundGray
                    : AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(12),
            border: isCurrentClass
                ? Border.all(
                    color: AppColors.primary,
                    width: 2,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppColors.backgroundLight
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
