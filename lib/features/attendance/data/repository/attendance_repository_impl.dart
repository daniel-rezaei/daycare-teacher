import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/attendance/data/data_source/attendance_api.dart';
import 'package:teacher_app/features/attendance/data/models/attendance_child_model/attendance_child_model.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/attendance/domain/repository/attendance_repository.dart';

@Singleton(as: AttendanceRepository, env: [Env.prod])
class AttendanceRepositoryImpl extends AttendanceRepository {
  final AttendanceApi attendanceApi;

  AttendanceRepositoryImpl(this.attendanceApi);

  @override
  Future<DataState<List<AttendanceChildEntity>>> getAttendanceByClassId({
    required String classId,
    String? childId,
  }) async {
    try {
      final Response response = await attendanceApi.getAttendanceByClassId(
        classId: classId,
        childId: childId,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;

      final List<AttendanceChildEntity> attendanceList = dataList
          .map(
            (data) =>
                AttendanceChildModel.fromJson(data as Map<String, dynamic>),
          )
          .toList();

      return DataSuccess(attendanceList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<AttendanceChildEntity>> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  }) async {
    try {
      final Response response = await attendanceApi.createAttendance(
        childId: childId,
        classId: classId,
        checkInAt: checkInAt,
        staffId: staffId,
      );

      final Map<String, dynamic> data =
          response.data['data'] as Map<String, dynamic>;
      final AttendanceChildEntity attendanceEntity =
          AttendanceChildModel.fromJson(data);

      return DataSuccess(attendanceEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<AttendanceChildEntity>> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo, // String of file ID (first file ID if multiple)
    String?
    pickupAuthorizationId, // DOMAIN LOCKDOWN: Only accepts existing PickupAuthorization ID
    String? checkoutPickupContactId, // Contact ID of the person picking up
  }) async {
    try {
      // DOMAIN LOCKDOWN: Checkout API accepts ONLY pickup_authorization_id
      // No contact/guardian/pickup creation allowed from checkout flow
      final Response response = await attendanceApi.updateAttendance(
        attendanceId: attendanceId,
        checkOutAt: checkOutAt,
        notes: notes,
        photo: photo,
        pickupAuthorizationId: pickupAuthorizationId,
        checkoutPickupContactId: checkoutPickupContactId,
      );

      final Map<String, dynamic> data =
          response.data['data'] as Map<String, dynamic>;
      final AttendanceChildEntity attendanceEntity =
          AttendanceChildModel.fromJson(data);
      return DataSuccess(attendanceEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'Error retrieving information';

    if (e.response != null) {
      errorMessage =
          e.response?.data['message'] ??
          e.response?.statusMessage ??
          'Error connecting to server';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Error connecting to server';
    }

    return DataFailed(errorMessage);
  }
}
