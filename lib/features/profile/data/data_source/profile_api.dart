import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ProfileApi {
  final Dio httpclient;
  ProfileApi(this.httpclient);

  // دریافت اطلاعات تماس بر اساس ID
  Future<Response> getContact({required String id}) async {
    return await httpclient.get('/items/Contacts/$id');
  }

  // دریافت همه Contacts
  Future<Response> getAllContacts() async {
    return await httpclient.get('/items/Contacts');
  }
}

