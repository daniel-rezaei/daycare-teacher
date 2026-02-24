import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ChildEmergencyContactApi {
  final Dio httpclient;
  ChildEmergencyContactApi(this.httpclient);

  Future<Response> getAllChildEmergencyContacts() async {
    return await httpclient.get('/items/Child_Emergency_Contact');
  }
}
