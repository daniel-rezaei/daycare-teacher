import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/services/time_in_access_guard.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/child_status/widgets/class_transfer_action_sheet.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class CardNotificationsWidget extends StatefulWidget {
  const CardNotificationsWidget({super.key});

  @override
  State<CardNotificationsWidget> createState() =>
      _CardNotificationsWidgetState();
}

class _CardNotificationsWidgetState extends State<CardNotificationsWidget> {
  String? classId;
  String? staffId;
  bool _hasRequestedSession = false;

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  Future<void> _loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString('class_id');
    final savedStaffId = prefs.getString('staff_id');
    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
        staffId = savedStaffId;
      });
      // بررسی اینکه آیا session قبلاً لود شده است
      final currentState = context.read<HomeBloc>().state;
      if (!_hasRequestedSession &&
          (currentState.session == null || currentState.isLoadingSession)) {
        _hasRequestedSession = true;
        context.read<HomeBloc>().add(LoadSessionEvent(savedClassId));
      }
    }
  }

  String? _getRoomName(List<ClassRoomEntity>? classRooms) {
    if (classId == null || classRooms == null) return null;

    try {
      final classRoom = classRooms.firstWhere((room) => room.id == classId);
      return classRoom.roomName;
    } catch (e) {
      return null;
    }
  }

  bool _isCheckedIn(StaffClassSessionEntity? session) {
    if (session == null) return false;
    // اگر start_at وجود دارد و end_at null است، یعنی check-in شده
    return session.startAt != null &&
        session.startAt!.isNotEmpty &&
        (session.endAt == null || session.endAt!.isEmpty);
  }

  String _getCurrentDateTime() {
    // Always return UTC ISO 8601 format for API
    final localNow = DateTime.now();
    final utcNow = localNow.toUtc();
    final utcIso = utcNow.toIso8601String();
    return utcIso;
  }

  void _handleCheckInOut(StaffClassSessionEntity? session) async {
    // اگر staffId null است، دوباره از SharedPreferences بخوانیم
    if (staffId == null || staffId!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final savedStaffId = prefs.getString('staff_id');
      if (!mounted) return;
      setState(() {
        staffId = savedStaffId;
      });
    }

    if (!mounted) return;
    if (classId == null || staffId == null || staffId!.isEmpty) {
      return;
    }

    final isCheckedIn = _isCheckedIn(session);
    final homeBloc = context.read<HomeBloc>();

    if (isCheckedIn) {
      // Check-out: Update existing session
      // No Time In validation needed for check-out
      if (session?.id != null && classId != null) {
        final endAt = _getCurrentDateTime();
        homeBloc.add(
          UpdateSessionEvent(
            sessionId: session!.id!,
            endAt: endAt,
            classId: classId!,
          ),
        );
      }
    } else {
      // Check-in: Create new session
      // Validation: User must have done Time In before starting the class
      final hasTimeIn = TimeInAccessGuard.checkActiveTimeInFromContext(context);

      if (!hasTimeIn) {
        // Block check-in and show message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You must Time In first before starting the class.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Time In is done, proceed with check-in
      final startAt = _getCurrentDateTime();
      homeBloc.add(
        CreateSessionEvent(
          staffId: staffId!,
          classId: classId!,
          startAt: startAt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String? roomName = _getRoomName(state.classRooms);
        StaffClassSessionEntity? session = state.session;
        bool isLoading = state.isLoadingSession;
        bool isProcessing = state.isProcessingSession;

        final isCheckedIn = _isCheckedIn(session);
        final displayText = isCheckedIn
            ? 'You have checked-in ${roomName ?? 'your class'}'
            : 'Your class hasn\'t started';
        final buttonText = isCheckedIn ? 'Class Check-Out' : 'Class Check-In';

        return Container(
          decoration: BoxDecoration(
            color: isCheckedIn
                ? Color(0xffF0E7FF)
                : Color(0xffDBDADD).withValues(alpha: .6),
            border: Border.all(width: 2, color: Color(0xffFAFAFA)),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: isCheckedIn
                    ? Color(0xffF0E7FF)
                    : Color(0xffE4D3FF).withValues(alpha: .5),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CupertinoActivityIndicator(radius: 10),
                      )
                    else
                      Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff444349),
                        ),
                      ),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (!isLoading && !isProcessing) {
                          if (isCheckedIn) {
                            // Class Check-Out: Open atomic transfer action sheet
                            // This allows teacher to: check out class, time out, and transfer to another class
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              useSafeArea: true,
                              builder: (context) => ClassTransferActionSheetWidget(
                                studentId:
                                    null, // Class-level transfer (no student)
                                currentClassId: classId ?? '',
                              ),
                            );
                          } else {
                            // Class Check-In: Use existing logic
                            _handleCheckInOut(session);
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isCheckedIn
                  ? Assets.images.check.image(height: 68)
                  : Assets.images.aIconNPng.image(height: 68),
            ],
          ),
        );
      },
    );
  }
}
