import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class PickupAuthorizationApi {
  final Dio httpclient;
  PickupAuthorizationApi(this.httpclient);

  Future<Response> getPickupAuthorizationByChildId({
    required String childId,
  }) async {
    return await httpclient.get(
      '/items/PickupAuthorization',
      queryParameters: {
        'filter[child_id][_eq]': childId,
        'fields': 'id,child_id,authorized_contact_id,relation_to_child,date_created,date_updated,user_created,user_updated',
      },
    );
  }
}
