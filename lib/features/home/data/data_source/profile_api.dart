import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ProfileApi {
  final Dio httpclient;
  ProfileApi(this.httpclient);

  Future<Response> getContact({required String id}) async {
    return await httpclient.get('/items/Contacts/$id');
  }

  Future<Response> getAllContacts() async {
    return await httpclient.get('/items/Contacts');
  }
}
