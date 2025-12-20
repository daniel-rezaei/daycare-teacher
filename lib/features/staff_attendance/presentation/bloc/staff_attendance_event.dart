part of 'staff_attendance_bloc.dart';

sealed class StaffAttendanceEvent extends Equatable {
  const StaffAttendanceEvent();

  @override
  List<Object> get props => [];
}

class GetStaffAttendanceByStaffIdEvent extends StaffAttendanceEvent {
  final String staffId;
  final String? startDate;
  final String? endDate;

  const GetStaffAttendanceByStaffIdEvent({
    required this.staffId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [staffId, startDate ?? '', endDate ?? ''];
}

/// دریافت آخرین رکورد Attendance_Staff
class GetLatestStaffAttendanceEvent extends StaffAttendanceEvent {
  final String staffId;

  const GetLatestStaffAttendanceEvent({required this.staffId});

  @override
  List<Object> get props => [staffId];
}

/// ثبت رویداد time_in یا time_out
class CreateStaffAttendanceEvent extends StaffAttendanceEvent {
  final String staffId;
  final String eventType; // 'time_in' or 'time_out'
  final String? classId;

  const CreateStaffAttendanceEvent({
    required this.staffId,
    required this.eventType,
    this.classId,
  });

  @override
  List<Object> get props => [staffId, eventType, classId ?? ''];
}

