import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/services/attendance_session_store.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';

/// Centralized access guard for Time-In protected features
/// Prevents access to classroom-related features when teacher is not Time-In
class TimeInAccessGuard {
  /// Check if teacher has active Time-In
  /// Returns true if active Time-In exists, false otherwise
  static bool hasActiveTimeIn(StaffAttendanceState state) {
    // Check GetLatestStaffAttendanceSuccess state
    if (state is GetLatestStaffAttendanceSuccess) {
      final latestAttendance = state.latestAttendance;
      // Active Time-In means latest attendance exists and is 'time_in' (not 'time_out')
      return latestAttendance != null &&
          latestAttendance.eventType == 'time_in';
    }
    
    // Check CreateStaffAttendanceSuccess state (after Time-In/Time-Out action)
    if (state is CreateStaffAttendanceSuccess) {
      final attendance = state.attendance;
      // If latest action was Time-In, we have active Time-In
      return attendance.eventType == 'time_in';
    }
    
    // If state is not success or is loading/failure/initial, assume no active Time-In
    // This is fail-safe: block access if we can't confirm active Time-In
    return false;
  }

  /// Check if teacher has active Time-In from current bloc state
  /// Returns true if active Time-In exists, false otherwise
  /// Also checks AttendanceSessionStore as a fallback to ensure accurate state
  static bool checkActiveTimeInFromContext(BuildContext context) {
    try {
      final state = context.read<StaffAttendanceBloc>().state;
      final hasActiveFromBloc = hasActiveTimeIn(state);
      
      // Also check the AttendanceSessionStore as a fallback
      // This ensures we have accurate state even if bloc state is not in a success state
      final timerStore = AttendanceSessionStore.instance;
      final hasActiveFromStore = timerStore.isClockedIn && timerStore.timeInAt != null;
      
      // If either source indicates active Time-In, return true
      // This prevents false negatives when bloc state hasn't updated yet
      return hasActiveFromBloc || hasActiveFromStore;
    } catch (e) {
      debugPrint('[TIME_IN_ACCESS_GUARD] Error checking state: $e');
      // On error, check the store as a fallback
      try {
        final timerStore = AttendanceSessionStore.instance;
        return timerStore.isClockedIn && timerStore.timeInAt != null;
      } catch (storeError) {
        debugPrint('[TIME_IN_ACCESS_GUARD] Error checking store: $storeError');
        return false;
      }
    }
  }

  /// Guard a protected action
  /// If no active Time-In, shows snackbar and returns false
  /// If active Time-In exists, returns true
  /// 
  /// Usage:
  /// ```dart
  /// if (!TimeInAccessGuard.guardAction(context)) return;
  /// // Proceed with protected action
  /// ```
  static bool guardAction(BuildContext context) {
    final hasActive = checkActiveTimeInFromContext(context);
    
    // The message "You must check in first" must ONLY be shown when:
    // - The user has NOT done Time In yet
    // If the user HAS already checked in and has NOT checked out yet, 
    // the message must NOT be shown and all buttons must work normally.
    if (!hasActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must check in first'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    
    return true;
  }

  /// Guard a protected navigation
  /// If no active Time-In, shows snackbar and prevents navigation
  /// If active Time-In exists, allows navigation
  /// 
  /// Usage:
  /// ```dart
  /// TimeInAccessGuard.guardNavigation(
  ///   context,
  ///   () => Navigator.push(context, MaterialPageRoute(...)),
  /// );
  /// ```
  static void guardNavigation(
    BuildContext context,
    VoidCallback navigationCallback,
  ) {
    if (guardAction(context)) {
      navigationCallback();
    }
  }

  /// Refresh Time-In status from API before checking
  /// Useful when you need to ensure latest status before guarding
  /// 
  /// Usage:
  /// ```dart
  /// await TimeInAccessGuard.refreshAndGuardAction(context);
  /// ```
  static Future<bool> refreshAndGuardAction(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString(AppConstants.staffIdKey);
      
      if (staffId == null || staffId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must check in first'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }

      // Request latest attendance status
      context.read<StaffAttendanceBloc>().add(
            GetLatestStaffAttendanceEvent(staffId: staffId),
          );

      // Wait a bit for the state to update (in real scenario, you'd use BlocListener)
      // For now, check current state
      await Future.delayed(const Duration(milliseconds: 100));
      
      return guardAction(context);
    } catch (e) {
      debugPrint('[TIME_IN_ACCESS_GUARD] Error refreshing status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must check in first'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }
}

