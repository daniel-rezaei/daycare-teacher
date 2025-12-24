import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  String? _staffId;
  String? _classId;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _lastEventAt;
  bool _isTimerReady = false; // Track if timer has been initialized with real data

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final staffId = prefs.getString('staff_id');
    final classId = prefs.getString(AppConstants.classIdKey);

    if (mounted && staffId != null && staffId.isNotEmpty) {
      setState(() {
        _staffId = staffId;
        _classId = classId;
      });

      // دریافت آخرین وضعیت از API
      context.read<StaffAttendanceBloc>().add(
            GetLatestStaffAttendanceEvent(staffId: staffId),
          );
    }
  }

  void _startTimer(DateTime eventAt) {
    _lastEventAt = eventAt;
    _timer?.cancel();
    
    // Calculate initial elapsed time immediately
    final initialElapsed = DateTime.now().difference(eventAt);
    if (mounted) {
      setState(() {
        _elapsed = initialElapsed;
        _isTimerReady = true; // Mark timer as ready
      });
    }
    
    // Start periodic updates
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _lastEventAt != null) {
        setState(() {
          _elapsed = DateTime.now().difference(_lastEventAt!);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _lastEventAt = null;
    if (mounted) {
      setState(() {
        _elapsed = Duration.zero;
        _isTimerReady = false; // Reset ready state
      });
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  bool _isRunning(StaffAttendanceEntity? latestAttendance) {
    if (latestAttendance == null) return false;
    return latestAttendance.eventType == 'time_in';
  }

  /// Check if class session is active (started but not ended)
  bool _isClassSessionActive(StaffClassSessionEntity? session) {
    if (session == null) return false;
    // Session is active if startAt exists and endAt is null/empty
    return session.startAt != null &&
        session.startAt!.isNotEmpty &&
        (session.endAt == null || session.endAt!.isEmpty);
  }

  /// Automatically end active class session when Time-Out happens
  /// This ensures class state is always synchronized with Time-In/Time-Out state
  void _autoEndActiveClassSession() {
    if (_classId == null || _classId!.isEmpty) {
      debugPrint('[TIME_SCREEN] Cannot end session: classId is null');
      return;
    }

    // Check current session state from HomeBloc
    final homeState = context.read<HomeBloc>().state;
    final session = homeState.session;

    if (_isClassSessionActive(session)) {
      // Active session exists - end it immediately
      if (session!.id == null || session.id!.isEmpty) {
        debugPrint('[TIME_SCREEN] Cannot end session: sessionId is null');
        return;
      }

      final endAt = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      debugPrint(
        '[TIME_SCREEN] Auto-ending class session on Time-Out: '
        'sessionId=${session.id}, endAt=$endAt',
      );

      // End the session by updating it with endAt timestamp
      context.read<HomeBloc>().add(
            UpdateSessionEvent(
              sessionId: session.id!,
              endAt: endAt,
              classId: _classId!,
            ),
          );
    } else {
      debugPrint('[TIME_SCREEN] No active class session to end');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundWidget(),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 34,
                ),
                child: Text(
                  'Time',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xffFFFFFF),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, -4),
                        blurRadius: 16,
                        color: Color(0xff000000).withValues(alpha: .1),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(40),
                  child: BlocConsumer<StaffAttendanceBloc, StaffAttendanceState>(
                    listener: (context, state) {
                      if (state is GetLatestStaffAttendanceSuccess) {
                        final latestAttendance = state.latestAttendance;
                        if (latestAttendance != null &&
                            latestAttendance.eventType == 'time_in' &&
                            latestAttendance.eventAt != null) {
                          try {
                            final eventAt = DateTime.parse(latestAttendance.eventAt!);
                            _startTimer(eventAt);
                          } catch (e) {
                            debugPrint('[TIME_SCREEN] Error parsing eventAt: $e');
                            _stopTimer();
                          }
                        } else {
                          _stopTimer();
                        }
                      } else if (state is CreateStaffAttendanceSuccess) {
                        // بعد از ثبت موفق، تایمر را به‌روزرسانی کن
                        final attendance = state.attendance;
                        if (attendance.eventType == 'time_in' &&
                            attendance.eventAt != null) {
                          try {
                            final eventAt = DateTime.parse(attendance.eventAt!);
                            _startTimer(eventAt);
                            // IMPORTANT: Do NOT auto-start class session on Time-In
                            // Teacher must manually start class session
                          } catch (e) {
                            debugPrint('[TIME_SCREEN] Error parsing eventAt: $e');
                            _stopTimer();
                          }
                        } else if (attendance.eventType == 'time_out') {
                          // Time-Out happened: Automatically end any active class session
                          _stopTimer();
                          _autoEndActiveClassSession();
                        } else {
                          _stopTimer();
                        }
                      } else if (state is GetLatestStaffAttendanceFailure ||
                          state is CreateStaffAttendanceFailure) {
                        // در صورت خطا، تایمر را متوقف کن
                        _stopTimer();
                      }
                    },
                    builder: (context, state) {
                      // دریافت آخرین وضعیت
                      StaffAttendanceEntity? latestAttendance;
                      bool isLoading = false;
                      String? errorMessage;

                      if (state is GetLatestStaffAttendanceLoading ||
                          state is CreateStaffAttendanceLoading) {
                        isLoading = true;
                      } else if (state is GetLatestStaffAttendanceSuccess) {
                        latestAttendance = state.latestAttendance;
                      } else if (state is GetLatestStaffAttendanceFailure) {
                        errorMessage = state.message;
                      } else if (state is CreateStaffAttendanceFailure) {
                        errorMessage = state.message;
                      }

                      final isRunning = _isRunning(latestAttendance);
                      final isProcessing = state is CreateStaffAttendanceLoading;
                      
                      // Determine if timer should be shown or loading indicator
                      // Show loading if: loading state OR timer is running but not ready yet
                      final showTimerLoading = isLoading || 
                          (isRunning && !_isTimerReady);

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 96),
                            child: isRunning
                                ? Assets.images.timeout.svg()
                                : Assets.images.timeIn.svg(),
                          ),
                          SizedBox(height: 24),
                          Text(
                            isRunning ? 'Time_Out' : 'Please Time_In First',
                            style: TextStyle(
                              color: Color(0xff444349),
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            isRunning
                                ? 'Are you sure you want to Time Out?'
                                : 'To access your account, make sure you\'ve timed in with your daycare',
                            style: TextStyle(
                              color: Color(0xff71717A).withValues(alpha: .8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),

                          // نمایش تایمر یا loading indicator
                          if (isRunning)
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xffF4F4F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: showTimerLoading
                                  ? const CupertinoActivityIndicator(
                                      radius: 16,
                                    )
                                  : Text(
                                      _formatDuration(_elapsed),
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),

                          // نمایش خطا
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          Spacer(),

                          // دکمه Time-In / Time-Out
                          ButtonWidget(
                            onTap: isLoading || isProcessing || _staffId == null
                                ? null
                                : () {
                                    if (isRunning) {
                                      // Time-Out
                                      context.read<StaffAttendanceBloc>().add(
                                            CreateStaffAttendanceEvent(
                                              staffId: _staffId!,
                                              eventType: 'time_out',
                                              classId: _classId,
                                            ),
                                          );
                                    } else {
                                      // Time-In
                                      context.read<StaffAttendanceBloc>().add(
                                            CreateStaffAttendanceEvent(
                                              staffId: _staffId!,
                                              eventType: 'time_in',
                                              classId: _classId,
                                            ),
                                          );
                                    }
                                  },
                            child: isLoading || isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CupertinoActivityIndicator(
                                      radius: 10,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isRunning ? 'Time-Out' : 'Time-In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
