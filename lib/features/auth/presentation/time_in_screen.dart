import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/home/my_home_page.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TimeInScreen extends StatefulWidget {
  const TimeInScreen({super.key});

  @override
  State<TimeInScreen> createState() => _TimeInScreenState();
}

class _TimeInScreenState extends State<TimeInScreen> {
  String? _staffId;
  String? _classId;

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  Future<void> _loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final staffId = prefs.getString(AppConstants.staffIdKey);
    final classId = prefs.getString(AppConstants.classIdKey);

    if (mounted) {
      setState(() {
        _staffId = staffId;
        _classId = classId;
      });
    }
  }

  void _handleTimeIn() {
    if (_staffId == null || _staffId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff ID not found. Please log in again.'),
        ),
      );
      return;
    }

    // Register Time-In using StaffAttendanceBloc
    context.read<StaffAttendanceBloc>().add(
          CreateStaffAttendanceEvent(
            staffId: _staffId!,
            eventType: 'time_in',
            classId: _classId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffAttendanceBloc, StaffAttendanceState>(
      listener: (context, state) {
        if (state is CreateStaffAttendanceSuccess) {
          // After successful Time-In registration, redirect to Home page
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MyHomePage()),
              (_) => false,
            );
          }
        } else if (state is CreateStaffAttendanceFailure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to register Time-In: ${state.message}'),
              ),
            );
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<StaffAttendanceBloc, StaffAttendanceState>(
            builder: (context, state) {
              final isProcessing = state is CreateStaffAttendanceLoading;
              
              return Column(
                children: [
                  BackTitleWidget(title: 'Time In', onTap: () {}),
                  SizedBox(height: 40),
                  Assets.images.timeIn.svg(),
                  SizedBox(height: 24),
                  Text(
                    'Staff Time- In Required',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'You must be on-site to Time-In',
                    style: TextStyle(
                      color: Color(0xff71717A).withValues(alpha: .8),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
                    child: AbsorbPointer(
                      absorbing: isProcessing || _staffId == null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ButtonWidget(
                            onTap: _handleTimeIn,
                            child: Text(
                              isProcessing ? '' : 'Time-In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isProcessing)
                            const CupertinoActivityIndicator(
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Scan your QR code to Time-In',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
