part of 'staff_schedule_bloc.dart';

sealed class StaffScheduleState extends Equatable {
  const StaffScheduleState();

  @override
  List<Object?> get props => [];
}

final class StaffScheduleInitial extends StaffScheduleState {
  const StaffScheduleInitial();
}

final class GetStaffScheduleByStaffIdLoading extends StaffScheduleState {
  const GetStaffScheduleByStaffIdLoading();
}

final class GetStaffScheduleByStaffIdSuccess extends StaffScheduleState {
  final List<Map<String, dynamic>> schedulesWithShiftDate;
  const GetStaffScheduleByStaffIdSuccess(this.schedulesWithShiftDate);
  @override
  List<Object?> get props => [schedulesWithShiftDate];
}

final class GetStaffScheduleByStaffIdFailure extends StaffScheduleState {
  final String message;
  const GetStaffScheduleByStaffIdFailure(this.message);
  @override
  List<Object?> get props => [message];
}
