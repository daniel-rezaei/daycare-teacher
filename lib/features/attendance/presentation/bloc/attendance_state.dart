part of 'attendance_bloc.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

final class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

/// Loading state for getting attendance by class_id
final class GetAttendanceByClassIdLoading extends AttendanceState {
  const GetAttendanceByClassIdLoading();
}

/// Success state for getting attendance by class_id
final class GetAttendanceByClassIdSuccess extends AttendanceState {
  final List<AttendanceChildEntity> attendanceList;

  const GetAttendanceByClassIdSuccess(this.attendanceList);

  @override
  List<Object?> get props => [attendanceList];
}

/// Failure state for getting attendance by class_id
final class GetAttendanceByClassIdFailure extends AttendanceState {
  final String message;

  const GetAttendanceByClassIdFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Loading state for creating attendance
final class CreateAttendanceLoading extends AttendanceState {
  const CreateAttendanceLoading();
}

/// Success state for creating attendance
final class CreateAttendanceSuccess extends AttendanceState {
  final AttendanceChildEntity attendance;

  const CreateAttendanceSuccess(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

/// Failure state for creating attendance
final class CreateAttendanceFailure extends AttendanceState {
  final String message;

  const CreateAttendanceFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Loading state for updating attendance
final class UpdateAttendanceLoading extends AttendanceState {
  const UpdateAttendanceLoading();
}

/// Success state for updating attendance
final class UpdateAttendanceSuccess extends AttendanceState {
  final AttendanceChildEntity attendance;
  const UpdateAttendanceSuccess(this.attendance);
  @override
  List<Object?> get props => [attendance];
}

/// Failure state for updating attendance
final class UpdateAttendanceFailure extends AttendanceState {
  final String message;
  const UpdateAttendanceFailure(this.message);
  @override
  List<Object> get props => [message];
}

