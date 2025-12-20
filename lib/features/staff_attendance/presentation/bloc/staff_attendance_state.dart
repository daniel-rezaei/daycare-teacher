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

/// States for GetLatestStaffAttendance
final class GetLatestStaffAttendanceLoading extends StaffAttendanceState {
  const GetLatestStaffAttendanceLoading();
}

final class GetLatestStaffAttendanceSuccess extends StaffAttendanceState {
  final StaffAttendanceEntity? latestAttendance;
  const GetLatestStaffAttendanceSuccess(this.latestAttendance);
  @override
  List<Object?> get props => [latestAttendance];
}

final class GetLatestStaffAttendanceFailure extends StaffAttendanceState {
  final String message;
  const GetLatestStaffAttendanceFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// States for CreateStaffAttendance
final class CreateStaffAttendanceLoading extends StaffAttendanceState {
  const CreateStaffAttendanceLoading();
}

final class CreateStaffAttendanceSuccess extends StaffAttendanceState {
  final StaffAttendanceEntity attendance;
  const CreateStaffAttendanceSuccess(this.attendance);
  @override
  List<Object?> get props => [attendance];
}

final class CreateStaffAttendanceFailure extends StaffAttendanceState {
  final String message;
  const CreateStaffAttendanceFailure(this.message);
  @override
  List<Object?> get props => [message];
}

