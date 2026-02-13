import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/features/auth/presentation/select_your_profile.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/transfer_class_widget.dart';
import 'package:teacher_app/features/class_transfer_request/presentation/bloc/class_transfer_request_bloc.dart';
import 'package:teacher_app/features/class_transfer_request/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';

/// ISOLATED MODULE: Atomic Class Transfer Action Sheet
///
/// This is a completely separate module from TransferClassWidget (LEGACY).
/// All atomic transaction logic, switches, and navigation rules live here exclusively.
///
/// ATOMIC TRANSACTION RULES:
/// - NO side effects on switch toggle or class selection
/// - All actions execute ONLY when Save is explicitly tapped
/// - Execution order: Check Out → Time Out → Transfer Request (if studentId provided) → Logout → Navigate
class ClassTransferActionSheetWidget extends StatefulWidget {
  final String?
  studentId; // Optional: only needed for student transfer requests
  final String currentClassId;

  const ClassTransferActionSheetWidget({
    super.key,
    this.studentId, // Optional for class-level transfer (no student)
    required this.currentClassId,
  });

  @override
  State<ClassTransferActionSheetWidget> createState() =>
      _ClassTransferActionSheetWidgetState();
}

class _ClassTransferActionSheetWidgetState extends State<ClassTransferActionSheetWidget> {
  String? selectedClassId;
  bool _isSubmitting = false;
  ClassTransferRequestEntity? _existingRequest;
  String? _staffId;

  // ATOMIC TRANSACTION: These switches only store state - NO side effects until Save
  bool _checkOutEnabled = false; // For CLASS CHECK-OUT (ending class session)
  bool _timeOutEnabled = false; // For SCHOOL TIME-OUT (staff attendance)

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
    // Check for existing pending transfer request (only if studentId is provided)
    if (widget.studentId != null && widget.studentId!.isNotEmpty) {
      context.read<ClassTransferRequestBloc>().add(
        GetTransferRequestByStudentIdEvent(studentId: widget.studentId!),
      );
    }
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
    if (_isSubmitting) return false;

    // Check for pending transfer request (only for student transfers)
    if (widget.studentId != null &&
        widget.studentId!.isNotEmpty &&
        _existingRequest != null &&
        _existingRequest!.status == 'pending') {
      return false;
    }

    // SCENARIO A & B: Allow save if check out or time out is enabled (even if no class change)
    final hasCheckOutOrTimeOut = _checkOutEnabled || _timeOutEnabled;

    // SCENARIO C: Allow save if class is changed (with or without check out/time out)
    final isClassChanged =
        selectedClassId != null && selectedClassId != widget.currentClassId;

    return hasCheckOutOrTimeOut || isClassChanged;
  }

  /// Check if class is actually being changed
  bool get _isClassChanged {
    return selectedClassId != null && selectedClassId != widget.currentClassId;
  }

  /// ATOMIC TRANSACTION: Execute all actions in exact order on Save only
  /// NO side effects allowed until Save is explicitly tapped
  Future<void> _handleSave() async {
    if (!_canSave) return;

    // Check if staffId is available (needed for time out and transfer requests)
    if ((_timeOutEnabled || _isClassChanged) &&
        (_staffId == null || _staffId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Staff ID not found')),
      );
      return;
    }

    // Prevent duplicate transfer requests (only for student transfers with class change)
    if (_isClassChanged &&
        widget.studentId != null &&
        widget.studentId!.isNotEmpty &&
        _existingRequest != null &&
        _existingRequest!.status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A transfer request is currently under review'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final isClassChanged = _isClassChanged;
      // Step 1: If Check out is ON → register CLASS CHECK-OUT for current class
      if (_checkOutEnabled) {
        final homeState = context.read<HomeBloc>().state;
        final session = homeState.session;

        // Check if class session is active (started but not ended)
        final isSessionActive =
            session != null &&
            session.startAt != null &&
            session.startAt!.isNotEmpty &&
            (session.endAt == null || session.endAt!.isEmpty);

        if (isSessionActive && session.id != null) {
          final endAt = DateFormat(
            'yyyy-MM-ddTHH:mm:ss',
          ).format(DateTime.now());
          // Wait for session update to complete
          await _waitForSessionUpdate(
            session.id!,
            endAt,
            widget.currentClassId,
          );
        }
      }

      // Step 2: If Time out is ON → register SCHOOL TIME-OUT for the teacher
      if (_timeOutEnabled) {
        context.read<StaffAttendanceBloc>().add(
          CreateStaffAttendanceEvent(
            staffId: _staffId!,
            eventType: 'time_out',
            classId: widget.currentClassId,
          ),
        );

        // Wait for time out to complete
        await _waitForTimeOut();
      }

      // SCENARIO A & B: NO CLASS CHANGE - Close sheet, no logout/navigation
      if (!isClassChanged) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _timeOutEnabled
                    ? 'Time out and check out completed successfully'
                    : 'Check out completed successfully',
              ),
            ),
          );
        }
        return; // Exit early - no logout, no navigation
      }

      // SCENARIO C: CLASS CHANGED - Proceed with full transfer flow

      // Step 3: Create transfer request (only if studentId is provided)
      if (widget.studentId != null && widget.studentId!.isNotEmpty) {
        context.read<ClassTransferRequestBloc>().add(
          CreateTransferRequestEvent(
            childId: widget.studentId!,
            fromClassId: widget.currentClassId,
            toClassId: selectedClassId!,
            requestedByStaffId: _staffId!,
          ),
        );

        // Wait for transfer request to complete
        await _waitForTransferRequest();
      }

      // Step 4: Perform LOGOUT (only when class is changed)
      final auth = ClerkAuth.of(context);
      await auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('class_id');
      await prefs.remove('contact_id');
      await prefs.remove('staff_id');
      await prefs.remove('selected_class');

      // Step 5: Navigate to Select Your Profile of the selected class
      // Step 6: Load staff list for that class (happens automatically via GetStaffClassEvent)
      if (mounted) {
        // Request staff classes for the selected class
        context.read<AuthBloc>().add(
          GetStaffClassEvent(classId: selectedClassId!),
        );

        // Navigation will happen via BlocListener when GetStaffClassSuccess is emitted
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error during transfer: $e')));
      }
    }
  }

  /// Wait for session update to complete
  Future<void> _waitForSessionUpdate(
    String sessionId,
    String endAt,
    String classId,
  ) async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = context.read<HomeBloc>().stream.listen((state) {
      if (state.session?.id == sessionId &&
          state.session?.endAt != null &&
          state.session!.endAt!.isNotEmpty) {
        if (!completer.isCompleted) {
          completer.complete();
          subscription.cancel();
        }
      }
    });

    context.read<HomeBloc>().add(
      UpdateSessionEvent(sessionId: sessionId, endAt: endAt, classId: classId),
    );

    // Wait with timeout
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription.cancel();
      },
    );
  }

  /// Wait for time out to complete
  Future<void> _waitForTimeOut() async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = context.read<StaffAttendanceBloc>().stream.listen((state) {
      if (state is CreateStaffAttendanceSuccess &&
          state.attendance.eventType == 'time_out') {
        if (!completer.isCompleted) {
          completer.complete();
          subscription.cancel();
        }
      } else if (state is CreateStaffAttendanceFailure) {
        if (!completer.isCompleted) {
          completer.complete();
          subscription.cancel();
        }
      }
    });

    // Wait with timeout
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription.cancel();
      },
    );
  }

  /// Wait for transfer request to complete
  Future<void> _waitForTransferRequest() async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = context.read<ClassTransferRequestBloc>().stream.listen((
      state,
    ) {
      if (state is CreateTransferRequestSuccess) {
        if (!completer.isCompleted) {
          completer.complete();
          subscription.cancel();
        }
      } else if (state is CreateTransferRequestFailure) {
        if (!completer.isCompleted) {
          completer.complete();
          subscription.cancel();
        }
      }
    });

    // Wait with timeout
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ClassTransferRequestBloc, ClassTransferRequestState>(
          listener: (context, state) {
            if (state is GetTransferRequestByStudentIdSuccess) {
              setState(() {
                _existingRequest = state.request;
              });
              // If there's a pending request, show a message
              if (state.request != null && state.request!.status == 'pending') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A transfer request is currently under review',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } else if (state is CreateTransferRequestSuccess) {
              // Transfer request created - navigation will happen via AuthBloc listener
              setState(() {
                _existingRequest = state.request;
              });
              // Refresh transfer requests list in the parent screen (only if studentId was provided)
              if (widget.studentId != null && widget.studentId!.isNotEmpty) {
                context.read<ClassTransferRequestBloc>().add(
                  GetTransferRequestsByClassIdEvent(
                    classId: widget.currentClassId,
                  ),
                );
              }
            } else if (state is CreateTransferRequestFailure) {
              setState(() {
                _isSubmitting = false;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        // Listen for GetStaffClassSuccess to navigate to Select Your Profile
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is GetStaffClassSuccess &&
                _isSubmitting &&
                selectedClassId != null) {
              // Close the action sheet
              Navigator.pop(context);

              // Navigate to Select Your Profile
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => SelectYourProfileScreen(
                    classId: selectedClassId!,
                    staffClasses: state.staffClasses,
                  ),
                ),
                (_) => false, // Remove all previous routes
              );

              setState(() {
                _isSubmitting = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfer completed successfully'),
                ),
              );
            }
          },
        ),
      ],
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
                        if (widget.studentId != null &&
                            widget.studentId!.isNotEmpty &&
                            _existingRequest != null &&
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
                        // Reuse TransferClassList from legacy widget (read-only component)
                        TransferClassListWidget(
                          rooms: classes,
                          selectedClassId: selectedClassId,
                          currentClassId: widget.currentClassId,
                          onClassSelected: (value) {
                            // ATOMIC: Only update state - NO side effects
                            setState(() {
                              selectedClassId = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      // ATOMIC TRANSACTION: Check out and Time out switches
                      // These only store state - NO side effects until Save
                      _buildSwitchRow(
                        title: 'Check Out',
                        value: _checkOutEnabled,
                        onChanged: (value) {
                          // ATOMIC: Only update state - NO side effects
                          setState(() {
                            _checkOutEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSwitchRow(
                        title: 'Time Out',
                        value: _timeOutEnabled,
                        onChanged: (value) {
                          // ATOMIC: Only update state - NO side effects
                          setState(() {
                            _timeOutEnabled = value;
                            // Auto-enable check out when time out is enabled
                            if (value) {
                              _checkOutEnabled = true;
                            }
                          });
                        },
                      ),
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

  /// Build switch row for check out/time out options
  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
