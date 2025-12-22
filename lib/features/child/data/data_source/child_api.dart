import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class ChildApi {
  final Dio httpclient;
  ChildApi(this.httpclient);

  // دریافت همه بچه‌ها
  Future<Response> getAllChildren() async {
    return await httpclient.get('/items/Child');
  }

  // دریافت لیست همه محدودیت‌های غذایی
  Future<Response> getAllDietaryRestrictions() async {
    return await httpclient.get('/items/Child_Dietary_Restrictions');
  }

  // دریافت لیست همه داروها
  Future<Response> getAllMedications() async {
    return await httpclient.get('/items/Medication');
  }

  // دریافت لیست همه نیازمندی‌های فیزیکی
  Future<Response> getAllPhysicalRequirements() async {
    return await httpclient.get('/items/child_physical_requirements');
  }

  // دریافت لیست همه بیماری‌های قابل گزارش
  Future<Response> getAllReportableDiseases() async {
    return await httpclient.get('/items/child_reportable_diseases');
  }

  // دریافت لیست همه واکسیناسیون‌ها
  Future<Response> getAllImmunizations() async {
    return await httpclient.get('/items/immunization');
  }

  // دریافت بچه بر اساس ID
  Future<Response> getChildById({required String childId}) async {
    return await httpclient.get(
      '/items/Child/$childId',
      queryParameters: {
        'fields': 'id,dob,language,photo,contact_id,status,date_created,date_updated',
      },
    );
  }

  // دریافت بچه بر اساس contact_id
  Future<Response> getChildByContactId({required String contactId}) async {
    return await httpclient.get(
      '/items/Child',
      queryParameters: {
        'filter[contact_id][_eq]': contactId,
        'fields': 'id,dob,language,photo,contact_id,status,date_created,date_updated',
        'limit': 1,
      },
    );
  }
}

