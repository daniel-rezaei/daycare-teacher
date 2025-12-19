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

