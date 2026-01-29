import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/attendance/domain/repository/attendance_repository.dart';

@singleton
class AttendanceUsecase {
  final AttendanceRepository attendanceRepository;

  AttendanceUsecase(this.attendanceRepository);

  // دریافت attendance بر اساس class_id
  Future<DataState<List<AttendanceChildEntity>>> getAttendanceByClassId({
    required String classId,
    String? childId,
  }) async {
    return await attendanceRepository.getAttendanceByClassId(
      classId: classId,
      childId: childId,
    );
  }

  // ایجاد attendance جدید
  Future<DataState<AttendanceChildEntity>> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  }) async {
    return await attendanceRepository.createAttendance(
      childId: childId,
      classId: classId,
      checkInAt: checkInAt,
      staffId: staffId,
    );
  }

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
  }) async {
    return await attendanceRepository.updateAttendance(
      attendanceId: attendanceId,
      checkOutAt: checkOutAt,
      notes: notes,
      photo: photo,
      pickupAuthorizationId: pickupAuthorizationId,
      checkoutPickupContactId: checkoutPickupContactId,
    );
  }
}

