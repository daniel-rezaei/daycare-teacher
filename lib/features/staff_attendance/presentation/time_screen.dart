import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/services/attendance_session_store.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
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
  final AttendanceSessionStore _store = AttendanceSessionStore.instance;

  @override
  void initState() {
    super.initState();
    _loadIds();
    _rehydrateFromStore();
    
    // Listen to store changes
    _store.addListener(_onStoreChanged);
    
    // Start timer if needed
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
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

      // Rehydrate from persistent storage first
      await _store.rehydrate();
      
      // Then fetch from API to ensure we have latest state
      context.read<StaffAttendanceBloc>().add(
            GetLatestStaffAttendanceEvent(staffId: staffId),
          );
    }
  }

  /// Rehydrate timer from store (persistent storage)
  void _rehydrateFromStore() {
    debugPrint(
      '[TIME_SCREEN] Rehydrating from store: '
      'isClockedIn=${_store.isClockedIn}, '
      'timeInAt=${_store.timeInAt}, '
      'accumulatedTotal=${_store.accumulatedTotal.inMinutes}min',
    );
    
    if (_store.isClockedIn && _store.timeInAt != null) {
      _startTimerIfNeeded();
    } else {
      _stopTimer();
    }
  }

  /// Start timer if store indicates active Time-In
  void _startTimerIfNeeded() {
    if (!_store.isClockedIn || _store.timeInAt == null) {
      _stopTimer();
      return;
    }

    // Only start if not already running
    if (_timer != null && _timer!.isActive) {
      return;
    }

    debugPrint(
      '[TIME_SCREEN] Starting timer from store: '
      'timeInAt=${_store.timeInAt}, '
      'accumulatedTotal=${_store.accumulatedTotal.inMinutes}min',
    );

    // Start periodic updates
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to show updated elapsed time
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {
        // Store changed, update UI
      });
      _startTimerIfNeeded();
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  /// Check if class session is active (started but not ended)
  bool _isClassSessionActive(StaffClassSessionEntity? session) {
    if (session == null) return false;
    return session.startAt != null &&
        session.startAt!.isNotEmpty &&
        (session.endAt == null || session.endAt!.isEmpty);
  }

  /// Automatically end active class session when Time-Out happens
  void _autoEndActiveClassSession() {
    if (_classId == null || _classId!.isEmpty) {
      debugPrint('[TIME_SCREEN] Cannot end session: classId is null');
      return;
    }

    final homeState = context.read<HomeBloc>().state;
    final session = homeState.session;

    if (_isClassSessionActive(session)) {
      if (session!.id == null || session.id!.isEmpty) {
        debugPrint('[TIME_SCREEN] Cannot end session: sessionId is null');
        return;
      }

      final endAt = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      debugPrint(
        '[TIME_SCREEN] Auto-ending class session on Time-Out: '
        'sessionId=${session.id}, endAt=$endAt',
      );

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
    // Get current elapsed time from store
    final currentElapsed = _store.getCurrentElapsed();
    final isRunning = _store.isClockedIn;
    final isTimerReady = isRunning && _store.timeInAt != null;

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
                        
                        debugPrint(
                          '[TIME_SCREEN] GetLatestStaffAttendanceSuccess: '
                          'eventType=${latestAttendance?.eventType}',
                        );
                        
                        // Store is already synced by bloc, just ensure timer is running
                        _startTimerIfNeeded();
                      } else if (state is CreateStaffAttendanceSuccess) {
                        final attendance = state.attendance;
                        
                        debugPrint(
                          '[TIME_SCREEN] CreateStaffAttendanceSuccess: '
                          'eventType=${attendance.eventType}',
                        );
                        
                        if (attendance.eventType == 'time_out') {
                          _stopTimer();
                          _autoEndActiveClassSession();
                        } else {
                          _startTimerIfNeeded();
                        }
                      } else if (state is GetLatestStaffAttendanceFailure ||
                          state is CreateStaffAttendanceFailure) {
                        debugPrint(
                          '[TIME_SCREEN] Error state: ${state.runtimeType}',
                        );
                        // On error, try to use store state
                        _startTimerIfNeeded();
                      }
                    },
                    builder: (context, state) {
                      bool isLoading = false;
                      String? errorMessage;

                      if (state is GetLatestStaffAttendanceLoading ||
                          state is CreateStaffAttendanceLoading) {
                        isLoading = true;
                      } else if (state is GetLatestStaffAttendanceFailure) {
                        errorMessage = state.message;
                      } else if (state is CreateStaffAttendanceFailure) {
                        errorMessage = state.message;
                      }

                      final isProcessing = state is CreateStaffAttendanceLoading;
                      
                      // Show loading if: loading state OR timer is running but not ready yet
                      final showTimerLoading = isLoading || 
                          (isRunning && !isTimerReady);

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
                                      _formatDuration(currentElapsed),
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
