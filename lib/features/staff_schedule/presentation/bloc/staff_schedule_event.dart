part of 'staff_schedule_bloc.dart';

sealed class StaffScheduleEvent extends Equatable {
  const StaffScheduleEvent();

  @override
  List<Object> get props => [];
}

class GetStaffScheduleByStaffIdEvent extends StaffScheduleEvent {
  final String staffId;

  const GetStaffScheduleByStaffIdEvent({required this.staffId});

  @override
  List<Object> get props => [staffId];
}

