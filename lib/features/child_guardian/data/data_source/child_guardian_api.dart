import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ChildGuardianApi {
  final Dio httpclient;
  ChildGuardianApi(this.httpclient);

  // دریافت Child_Guardian بر اساس child_id
  Future<Response> getChildGuardianByChildId({
    required String childId,
  }) async {
    return await httpclient.get(
      '/items/Child_Guardian',
      queryParameters: {
        'filter[child_id][_eq]': childId,
        'fields': 'id,child_id,contact_id,relation,pickup_authorized,date_created,date_updated',
      },
    );
  }
}

