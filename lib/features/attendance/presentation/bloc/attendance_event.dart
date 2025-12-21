part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching attendance by class_id
class GetAttendanceByClassIdEvent extends AttendanceEvent {
  final String classId;
  final String? childId;

  const GetAttendanceByClassIdEvent({
    required this.classId,
    this.childId,
  });

  @override
  List<Object> get props => [classId, childId ?? ''];
}

/// Event for creating a new attendance
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

/// Event for updating attendance (check out)
class UpdateAttendanceEvent extends AttendanceEvent {
  final String attendanceId;
  final String classId;
  final String checkOutAt;
  final String? notes;
  final String? photo; // String of file ID (first file ID if multiple)
  final String? checkoutPickupContactId;
  final String? checkoutPickupContactType;

  const UpdateAttendanceEvent({
    required this.attendanceId,
    required this.classId,
    required this.checkOutAt,
    this.notes,
    this.photo,
    this.checkoutPickupContactId,
    this.checkoutPickupContactType,
  });

  @override
  List<Object> get props => [
        attendanceId,
        classId,
        checkOutAt,
        notes ?? '',
        photo ?? '',
        checkoutPickupContactId ?? '',
        checkoutPickupContactType ?? '',
      ];
}

