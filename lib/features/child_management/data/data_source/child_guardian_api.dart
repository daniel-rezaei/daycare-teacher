import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ChildGuardianApi {
  final Dio httpclient;
  ChildGuardianApi(this.httpclient);

  Future<Response> getChildGuardianByChildId({
    required String childId,
  }) async {
    return await httpclient.get(
      '/items/Child_Guardian',
      queryParameters: {
        'filter[child_id][_eq]': childId,
        'fields':
            'id,child_id,contact_id,relation,pickup_authorized,date_created,date_updated',
      },
    );
  }
}
