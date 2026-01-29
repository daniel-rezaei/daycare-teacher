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
/// DOMAIN LOCKDOWN: Checkout API accepts ONLY pickup_authorization_id
/// No contact/guardian/pickup creation allowed from checkout flow
class UpdateAttendanceEvent extends AttendanceEvent {
  final String attendanceId;
  final String checkOutAt;
  final String? notes;
  final String? photo; // String of file ID (first file ID if multiple)
  final String? pickupAuthorizationId; // ONLY accepts existing PickupAuthorization ID
  final String? checkoutPickupContactId; // Contact ID of the person picking up

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

