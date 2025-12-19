import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class PickupAuthorizationApi {
  final Dio httpclient;
  PickupAuthorizationApi(this.httpclient);

  // دریافت PickupAuthorization بر اساس child_id
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

  // ایجاد PickupAuthorization جدید
  Future<Response> createPickupAuthorization({
    required String childId,
    required String authorizedContactId,
    String? note,
  }) async {
    return await httpclient.post(
      '/items/PickupAuthorization',
      data: {
        'child_id': childId,
        'authorized_contact_id': authorizedContactId,
        'Note': note,
      },
    );
  }
}

