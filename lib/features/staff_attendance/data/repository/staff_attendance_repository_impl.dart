import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/staff_attendance/data/data_source/staff_attendance_api.dart';
import 'package:teacher_app/features/staff_attendance/data/models/staff_attendance_model/staff_attendance_model.dart';
import 'package:teacher_app/features/staff_attendance/domain/entity/staff_attendance_entity.dart';
import 'package:teacher_app/features/staff_attendance/domain/repository/staff_attendance_repository.dart';

@Singleton(as: StaffAttendanceRepository, env: [Env.prod])
class StaffAttendanceRepositoryImpl extends StaffAttendanceRepository {
  final StaffAttendanceApi staffAttendanceApi;

  StaffAttendanceRepositoryImpl(this.staffAttendanceApi);

  @override
  Future<DataState<List<StaffAttendanceEntity>>> getStaffAttendanceByStaffId({
    required String staffId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Response response = await staffAttendanceApi.getStaffAttendanceByStaffId(
        staffId: staffId,
        startDate: startDate,
        endDate: endDate,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<StaffAttendanceEntity> attendanceList = dataList
          .map((data) => StaffAttendanceModel.fromJson(data as Map<String, dynamic>))
          .toList();

      return DataSuccess(attendanceList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<StaffAttendanceEntity?>> getLatestStaffAttendance({
    required String staffId,
  }) async {
    try {
      final Response response = await staffAttendanceApi.getLatestStaffAttendance(
        staffId: staffId,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        return DataSuccess(null);
      }

      final StaffAttendanceEntity attendance = StaffAttendanceModel.fromJson(
        dataList[0] as Map<String, dynamic>,
      );

      return DataSuccess(attendance);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<StaffAttendanceEntity>> createStaffAttendance({
    required String staffId,
    required String eventType,
    required String eventAt,
    String? classId,
  }) async {
    try {
      final Response response = await staffAttendanceApi.createStaffAttendance(
        staffId: staffId,
        eventType: eventType,
        eventAt: eventAt,
        classId: classId,
      );

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final StaffAttendanceEntity attendance = StaffAttendanceModel.fromJson(data);

      return DataSuccess(attendance);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'Error retrieving information';

    if (e.response != null) {
      errorMessage = e.response?.data['message'] ??
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

