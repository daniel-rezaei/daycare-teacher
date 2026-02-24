import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';

abstract class AttendanceRepository {
  Future<DataState<List<AttendanceChildEntity>>> getAttendanceByClassId({
    required String classId,
    String? childId,
  });

  Future<DataState<AttendanceChildEntity>> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  });

  Future<DataState<AttendanceChildEntity>> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo,
    String? pickupAuthorizationId,
    String? checkoutPickupContactId,
  });
}
