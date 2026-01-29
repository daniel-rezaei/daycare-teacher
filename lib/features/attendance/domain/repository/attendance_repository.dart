import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';

abstract class AttendanceRepository {
  // دریافت attendance بر اساس class_id
  Future<DataState<List<AttendanceChildEntity>>> getAttendanceByClassId({
    required String classId,
    String? childId,
  });

  // ایجاد attendance جدید
  Future<DataState<AttendanceChildEntity>> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  });

  // به‌روزرسانی attendance (برای check out)
  // DOMAIN LOCKDOWN: Checkout API accepts ONLY pickup_authorization_id
  // No contact/guardian/pickup creation allowed from checkout flow
  Future<DataState<AttendanceChildEntity>> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo, // String of file ID (first file ID if multiple)
    String? pickupAuthorizationId, // ONLY accepts existing PickupAuthorization ID
    String? checkoutPickupContactId, // Contact ID of the person picking up
  });
}
