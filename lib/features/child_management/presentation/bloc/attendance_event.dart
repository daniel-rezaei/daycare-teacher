part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object> get props => [];
}

class GetAttendanceByClassIdEvent extends AttendanceEvent {
  final String classId;
  final String? childId;
  const GetAttendanceByClassIdEvent({required this.classId, this.childId});
  @override
  List<Object> get props => [classId, childId ?? ''];
}

class CreateAttendanceEvent extends AttendanceEvent {
  final String childId;
  final String classId;
  final String checkInAt;
  final String? staffId;
  const CreateAttendanceEvent({
    required this.childId,
    required this.classId,
    required this.checkInAt,
    this.staffId,
  });
  @override
  List<Object> get props => [childId, classId, checkInAt, staffId ?? ''];
}

class UpdateAttendanceEvent extends AttendanceEvent {
  final String attendanceId;
  final String checkOutAt;
  final String? notes;
  final String? photo;
  final String? pickupAuthorizationId;
  final String? checkoutPickupContactId;
  const UpdateAttendanceEvent({
    required this.attendanceId,
    required this.checkOutAt,
    this.notes,
    this.photo,
    this.pickupAuthorizationId,
    this.checkoutPickupContactId,
  });
  @override
  List<Object> get props => [
        attendanceId,
        checkOutAt,
        notes ?? '',
        photo ?? '',
        pickupAuthorizationId ?? '',
        checkoutPickupContactId ?? '',
      ];
}
