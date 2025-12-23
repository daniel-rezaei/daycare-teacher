import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/staff_schedule/data/data_source/staff_schedule_api.dart';
import 'package:teacher_app/features/staff_schedule/data/models/shift_date_model/shift_date_model.dart';
import 'package:teacher_app/features/staff_schedule/data/models/staff_schedule_model/staff_schedule_model.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/shift_date_entity.dart';
import 'package:teacher_app/features/staff_schedule/domain/entity/staff_schedule_entity.dart';
import 'package:teacher_app/features/staff_schedule/domain/repository/staff_schedule_repository.dart';

@Singleton(as: StaffScheduleRepository, env: [Env.prod])
class StaffScheduleRepositoryImpl extends StaffScheduleRepository {
  final StaffScheduleApi staffScheduleApi;

  StaffScheduleRepositoryImpl(this.staffScheduleApi);

  @override
  Future<DataState<List<StaffScheduleEntity>>> getStaffScheduleByStaffId({
    required String staffId,
  }) async {
    try {
      final Response response = await staffScheduleApi.getStaffScheduleByStaffId(
        staffId: staffId,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<StaffScheduleEntity> scheduleList = dataList
          .map((data) => StaffScheduleModel.fromJson(data as Map<String, dynamic>))
          .toList();

      return DataSuccess(scheduleList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<ShiftDateEntity>> getShiftDateById({
    required String shiftDateId,
  }) async {
    try {
      final Response response = await staffScheduleApi.getShiftDateById(
        shiftDateId: shiftDateId,
      );

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final ShiftDateEntity shiftDate = ShiftDateModel.fromJson(data);

      return DataSuccess(shiftDate);
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

