part of 'staff_attendance_bloc.dart';

sealed class StaffAttendanceState extends Equatable {
  const StaffAttendanceState();

  @override
  List<Object?> get props => [];
}

final class StaffAttendanceInitial extends StaffAttendanceState {
  const StaffAttendanceInitial();
}

final class GetStaffAttendanceByStaffIdLoading extends StaffAttendanceState {
  const GetStaffAttendanceByStaffIdLoading();
}

final class GetStaffAttendanceByStaffIdSuccess extends StaffAttendanceState {
  final List<StaffAttendanceEntity> attendanceList;
  const GetStaffAttendanceByStaffIdSuccess(this.attendanceList);
  @override
  List<Object?> get props => [attendanceList];
}

final class GetStaffAttendanceByStaffIdFailure extends StaffAttendanceState {
  final String message;
  const GetStaffAttendanceByStaffIdFailure(this.message);
  @override
  List<Object?> get props => [message];
}

