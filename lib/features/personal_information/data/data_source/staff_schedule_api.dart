import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class StaffScheduleApi {
  final Dio httpclient;
  StaffScheduleApi(this.httpclient);

  Future<Response> getStaffScheduleByStaffId({
    required String staffId,
  }) async {
    return await httpclient.get(
      '/items/Staff_Schedule',
      queryParameters: {
        'filter[staff_id][_eq]': staffId,
        'fields': 'id,staff_id,start_date,end_date,shift_date_id,date_created,date_updated',
        'sort': '-date_created',
      },
    );
  }

  Future<Response> getShiftDateById({
    required String shiftDateId,
  }) async {
    return await httpclient.get(
      '/items/Shift_Date/$shiftDateId',
      queryParameters: {
        'fields': 'id,days_of_week,start_time,end_time,date_created,date_updated',
      },
    );
  }

  Future<Response> getStaffScheduleWithShiftDate({
    required String staffId,
  }) async {
    return await httpclient.get(
      '/items/Staff_Schedule',
      queryParameters: {
        'filter[staff_id][_eq]': staffId,
        'fields': 'id,staff_id,start_date,end_date,shift_date_id.id,shift_date_id.days_of_week,shift_date_id.start_time,shift_date_id.end_time,date_created,date_updated',
        'sort': '-date_created',
      },
    );
  }
}
