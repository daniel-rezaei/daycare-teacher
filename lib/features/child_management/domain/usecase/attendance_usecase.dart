import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/attendance_repository.dart';

@singleton
class AttendanceUsecase {
  final AttendanceRepository attendanceRepository;

  AttendanceUsecase(this.attendanceRepository);

  Future<DataState<List<AttendanceChildEntity>>> getAttendanceByClassId({
    required String classId,
    String? childId,
  }) async =>
      await attendanceRepository.getAttendanceByClassId(
          classId: classId, childId: childId);

  Future<DataState<AttendanceChildEntity>> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  }) async =>
      await attendanceRepository.createAttendance(
        childId: childId,
        classId: classId,
        checkInAt: checkInAt,
        staffId: staffId,
      );

  Future<DataState<AttendanceChildEntity>> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo,
    String? pickupAuthorizationId,
    String? checkoutPickupContactId,
  }) async =>
      await attendanceRepository.updateAttendance(
        attendanceId: attendanceId,
        checkOutAt: checkOutAt,
        notes: notes,
        photo: photo,
        pickupAuthorizationId: pickupAuthorizationId,
        checkoutPickupContactId: checkoutPickupContactId,
      );
}
