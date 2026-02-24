part of 'attendance_bloc.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

final class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

final class GetAttendanceByClassIdLoading extends AttendanceState {
  const GetAttendanceByClassIdLoading();
}

final class GetAttendanceByClassIdSuccess extends AttendanceState {
  final List<AttendanceChildEntity> attendanceList;
  const GetAttendanceByClassIdSuccess(this.attendanceList);
  @override
  List<Object?> get props => [attendanceList];
}

final class GetAttendanceByClassIdFailure extends AttendanceState {
  final String message;
  const GetAttendanceByClassIdFailure(this.message);
  @override
  List<Object> get props => [message];
}

final class CreateAttendanceLoading extends AttendanceState {
  const CreateAttendanceLoading();
}

final class CreateAttendanceSuccess extends AttendanceState {
  final AttendanceChildEntity attendance;
  const CreateAttendanceSuccess(this.attendance);
  @override
  List<Object?> get props => [attendance];
}

final class CreateAttendanceFailure extends AttendanceState {
  final String message;
  const CreateAttendanceFailure(this.message);
  @override
  List<Object> get props => [message];
}

final class UpdateAttendanceLoading extends AttendanceState {
  const UpdateAttendanceLoading();
}

final class UpdateAttendanceSuccess extends AttendanceState {
  final AttendanceChildEntity attendance;
  const UpdateAttendanceSuccess(this.attendance);
  @override
  List<Object?> get props => [attendance];
}

final class UpdateAttendanceFailure extends AttendanceState {
  final String message;
  const UpdateAttendanceFailure(this.message);
  @override
  List<Object> get props => [message];
}
