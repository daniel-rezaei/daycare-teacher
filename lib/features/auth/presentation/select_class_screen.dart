import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/features/auth/presentation/select_your_profile.dart';
import 'package:teacher_app/features/child_status_module/widgets/transfer_class_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class SelectClassScreen extends StatefulWidget {
  final List<ClassRoomEntity> classRooms;
  final bool fromSharedModeSwitch; // CRITICAL: Flag indicating navigation from Shared Mode switch

  const SelectClassScreen({
    super.key,
    required this.classRooms,
    this.fromSharedModeSwitch = false,
  });

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  String? selectedClassId;
  DateTime? _lastBackPressTime; // For double-tap to exit

  @override
  Widget build(BuildContext context) {
    final rooms = widget.classRooms.where((e) => e.id != null).toList();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is GetStaffClassSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectYourProfileScreen(
                classId: selectedClassId!,
                staffClasses: state.staffClasses,
              ),
            ),
          );
        }
      },
      child: PopScope(
        // CRITICAL: Intercept back button when fromSharedModeSwitch is true
        canPop: !widget.fromSharedModeSwitch,
        onPopInvokedWithResult: widget.fromSharedModeSwitch
            ? (didPop, result) async {
                if (didPop) return;
                await _handleBackPress();
              }
            : null,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // CRITICAL: Hide back arrow when fromSharedModeSwitch is true
                if (!widget.fromSharedModeSwitch)
                  BackTitleWidget(
                    title: 'Select Class',
                    onTap: () => Navigator.pop(context),
                  )
                else
                  // Show title without back button when from Shared Mode switch
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 32), // Spacer to align with other screens
                        const Text(
                          'Select Class',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

              const SizedBox(height: 40),
              Assets.images.logoSample.image(height: 116),

              const SizedBox(height: 24),
              const Text(
                'Select Your Class',
                style: TextStyle(
                  color: Color(0xff444349),
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Choose the class you want to access',
                style: TextStyle(
                  color: const Color(0xff71717A).withValues(alpha: .8),
                ),
              ),

              const SizedBox(height: 48),

              TransferClassListWidget(
                rooms: rooms,
                selectedClassId: selectedClassId,
                onClassSelected: (classId) {
                  setState(() {
                    selectedClassId = classId;
                  });
                },
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is GetStaffClassLoading;

                    return AbsorbPointer(
                      absorbing: isLoading || selectedClassId == null,
                      child: ButtonWidget(
                        isEnabled: selectedClassId != null && !isLoading,
                        onTap: () {
                          context.read<AuthBloc>().add(
                            GetStaffClassEvent(classId: selectedClassId!),
                          );
                        },
                        child: isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// CRITICAL: Handle back button press when from Shared Mode switch
  /// Shows "Press back again to exit the app" on first press
  /// Exits app on second press within 2 seconds
  Future<void> _handleBackPress() async {
    final now = DateTime.now();
    
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // First press or more than 2 seconds since last press
      _lastBackPressTime = now;
      
      if (mounted) {
        CustomSnackbar.showInfo(context, 'Press back again to exit the app');
      }
    } else {
      // Second press within 2 seconds - exit app
      if (mounted) {
        SystemNavigator.pop();
      }
    }
  }
}
