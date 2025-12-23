import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child/data/data_source/child_api.dart';
import 'package:teacher_app/features/child/data/models/child_model/child_model.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/domain/repository/child_repository.dart';
import 'package:teacher_app/features/dietary_restriction/data/models/dietary_restriction_model/dietary_restriction_model.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/immunization/data/models/immunization_model/immunization_model.dart';
import 'package:teacher_app/features/immunization/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/medication/data/models/medication_model/medication_model.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/physical_requirement/data/models/physical_requirement_model/physical_requirement_model.dart';
import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/profile/data/data_source/profile_api.dart';
import 'package:teacher_app/features/profile/data/models/contact_model/contact_model.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/reportable_disease/data/models/reportable_disease_model/reportable_disease_model.dart';
import 'package:teacher_app/features/reportable_disease/domain/entity/reportable_disease_entity.dart';

@Singleton(as: ChildRepository, env: [Env.prod])
class ChildRepositoryImpl extends ChildRepository {
  final ChildApi childApi;
  final ProfileApi profileApi;

  ChildRepositoryImpl(this.childApi, this.profileApi);

  @override
  Future<DataState<List<ChildEntity>>> getAllChildren() async {
    try {
      final Response response = await childApi.getAllChildren();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<ChildEntity> childrenEntity = list
          .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(childrenEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<ContactEntity>>> getAllContacts() async {
    try {
      final Response response = await profileApi.getAllContacts();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<ContactEntity> contactsEntity = list
          .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(contactsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<DietaryRestrictionEntity>>> getAllDietaryRestrictions() async {
    try {
      final Response response = await childApi.getAllDietaryRestrictions();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<DietaryRestrictionEntity> restrictionsEntity = list
          .map((e) => DietaryRestrictionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(restrictionsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<MedicationEntity>>> getAllMedications() async {
    try {
      final Response response = await childApi.getAllMedications();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<MedicationEntity> medicationsEntity = list
          .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(medicationsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<PhysicalRequirementEntity>>> getAllPhysicalRequirements() async {
    try {
      final Response response = await childApi.getAllPhysicalRequirements();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<PhysicalRequirementEntity> requirementsEntity = list
          .map((e) => PhysicalRequirementModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(requirementsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<ReportableDiseaseEntity>>> getAllReportableDiseases() async {
    try {
      final Response response = await childApi.getAllReportableDiseases();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<ReportableDiseaseEntity> diseasesEntity = list
          .map((e) => ReportableDiseaseModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(diseasesEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<ImmunizationEntity>>> getAllImmunizations() async {
    try {
      final Response response = await childApi.getAllImmunizations();

      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<ImmunizationEntity> immunizationsEntity = list
          .map((e) => ImmunizationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(immunizationsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<ChildEntity>> getChildById({required String childId}) async {
    try {
      final Response response = await childApi.getChildById(childId: childId);

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final ChildEntity childEntity = ChildModel.fromJson(data);

      return DataSuccess(childEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<ChildEntity>> getChildByContactId({required String contactId}) async {
    try {
      debugPrint('[CHILD_REPO] ========== getChildByContactId START ==========');
      debugPrint('[CHILD_REPO] 📥 contactId: $contactId');
      
      final Response response = await childApi.getChildByContactId(contactId: contactId);

      debugPrint('[CHILD_REPO] ✅ API response received');
      debugPrint('[CHILD_REPO] 📦 Response data type: ${response.data.runtimeType}');
      
      if (response.data == null || response.data['data'] == null) {
        debugPrint('[CHILD_REPO] ⚠️ Response data is null');
        return DataFailed('Child not found for contactId: $contactId');
      }

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      debugPrint('[CHILD_REPO] 📊 Data list length: ${dataList.length}');
      
      if (dataList.isEmpty) {
        debugPrint('[CHILD_REPO] ⚠️ Data list is empty');
        return DataFailed('Child not found for contactId: $contactId');
      }

      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      debugPrint('[CHILD_REPO] 📋 Child data keys: ${data.keys.toList()}');
      debugPrint('[CHILD_REPO] 📋 Child dob value: ${data['dob']}');
      debugPrint('[CHILD_REPO] 📋 Child id: ${data['id']}');
      debugPrint('[CHILD_REPO] 📋 Child contact_id: ${data['contact_id']}');
      
      final ChildEntity childEntity = ChildModel.fromJson(data);
      
      debugPrint('[CHILD_REPO] ✅ ChildEntity created: id=${childEntity.id}, dob=${childEntity.dob}');
      debugPrint('[CHILD_REPO] ========== getChildByContactId SUCCESS ==========');

      return DataSuccess(childEntity);
    } on DioException catch (e) {
      debugPrint('[CHILD_REPO] ❌ DioException: ${e.message}');
      debugPrint('[CHILD_REPO] ========== getChildByContactId ERROR ==========');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint('[CHILD_REPO] ❌ Unexpected error: $e');
      debugPrint('[CHILD_REPO] Stack trace: $stackTrace');
      debugPrint('[CHILD_REPO] ========== getChildByContactId ERROR ==========');
      return DataFailed('Error retrieving child information: $e');
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    String errorMessage = 'Error retrieving information';
    
    if (e.response != null) {
      errorMessage = e.response?.data['message'] ?? 
                     e.response?.statusMessage ?? 
                     'Error connecting to server';
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Error connecting to server';
    }

    return DataFailed(errorMessage);
  }
}

