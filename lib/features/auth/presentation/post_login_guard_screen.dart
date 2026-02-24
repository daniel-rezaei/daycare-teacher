import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/app_loading_screen.dart';
import 'package:teacher_app/features/auth/presentation/time_in_screen.dart';
import 'package:teacher_app/features/home/my_home_page.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';

/// Post-login guard screen that checks for active Time-In status
/// and redirects to appropriate screen
class PostLoginGuardScreen extends StatefulWidget {
  const PostLoginGuardScreen({super.key});

  @override
  State<PostLoginGuardScreen> createState() => _PostLoginGuardScreenState();
}

class _PostLoginGuardScreenState extends State<PostLoginGuardScreen> {
  @override
  void initState() {
    super.initState();
    _checkTimeInStatus();
  }

  Future<void> _checkTimeInStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString(AppConstants.staffIdKey);

      if (staffId == null || staffId.isEmpty) {
        // No staff_id means we need to go to Time-In screen
        // This could happen if staff_id wasn't saved properly
        if (mounted) {
          _redirectToTimeIn();
        }
        return;
      }

      // Request latest attendance to check for active Time-In
      if (mounted) {
        context.read<StaffAttendanceBloc>().add(
          GetLatestStaffAttendanceEvent(staffId: staffId),
        );
      }
    } catch (e) {
      if (mounted) {
        _redirectToTimeIn();
      }
    }
  }

  void _redirectToTimeIn() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const TimeInScreen()));
  }

  void _redirectToHome() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffAttendanceBloc, StaffAttendanceState>(
      listener: (context, state) {
        if (state is GetLatestStaffAttendanceSuccess) {
          final latestAttendance = state.latestAttendance;

          // Check if there's an active Time-In
          // Active Time-In means:
          // 1. Latest attendance exists
          // 2. Latest attendance is 'time_in' (not 'time_out')
          final hasActiveTimeIn =
              latestAttendance != null &&
              latestAttendance.eventType == 'time_in';

          if (hasActiveTimeIn) {
            _redirectToHome();
          } else {
            _redirectToTimeIn();
          }
        } else if (state is GetLatestStaffAttendanceFailure) {
          _redirectToTimeIn();
        }
      },
      child: const AppLoadingScreen(),
    );
  }
}
