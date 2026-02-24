import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ChildApi {
  final Dio httpclient;
  ChildApi(this.httpclient);

  Future<Response> getAllChildren() async {
    return await httpclient.get('/items/Child');
  }

  Future<Response> getAllDietaryRestrictions() async {
    return await httpclient.get('/items/child_dietary_restrictions');
  }

  Future<Response> getAllMedications() async {
    return await httpclient.get('/items/Medication');
  }

  Future<Response> getAllPhysicalRequirements() async {
    return await httpclient.get('/items/child_physical_requirements');
  }

  Future<Response> getAllReportableDiseases() async {
    return await httpclient.get('/items/child_reportable_diseases');
  }

  Future<Response> getAllImmunizations() async {
    return await httpclient.get('/items/Immunization');
  }

  Future<Response> getAllAllergies() async {
    return await httpclient.get('/items/child_allergies');
  }

  Future<Response> getChildById({required String childId}) async {
    return await httpclient.get(
      '/items/Child/$childId',
      queryParameters: {
        'fields':
            'id,dob,language,photo,contact_id,status,date_created,date_updated',
      },
    );
  }

  Future<Response> getChildByContactId({required String contactId}) async {
    return await httpclient.get(
      '/items/Child',
      queryParameters: {
        'filter[contact_id][_eq]': contactId,
        'fields':
            'id,dob,language,photo,contact_id,status,date_created,date_updated',
        'limit': 1,
      },
    );
  }
}
