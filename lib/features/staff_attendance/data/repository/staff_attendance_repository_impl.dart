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

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'خطا در دریافت اطلاعات';

    if (e.response != null) {
      errorMessage = e.response?.data['message'] ??
          e.response?.statusMessage ??
          'خطا در ارتباط با سرور';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'زمان اتصال به سرور به پایان رسید';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'خطا در اتصال به سرور';
    }

    return DataFailed(errorMessage);
  }
}

