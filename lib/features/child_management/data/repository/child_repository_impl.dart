import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child_management/data/data_source/child_api.dart';
import 'package:teacher_app/features/child_management/data/models/allergy_model.dart';
import 'package:teacher_app/features/child_management/data/models/child_model.dart';
import 'package:teacher_app/features/child_management/data/models/dietary_restriction_model.dart';
import 'package:teacher_app/features/child_management/data/models/immunization_model.dart';
import 'package:teacher_app/features/child_management/data/models/medication_model.dart';
import 'package:teacher_app/features/child_management/data/models/physical_requirement_model.dart';
import 'package:teacher_app/features/child_management/data/models/reportable_disease_model.dart';
import 'package:teacher_app/features/child_management/domain/entity/allergy_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/reportable_disease_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_repository.dart';
import 'package:teacher_app/features/home/data/data_source/profile_api.dart';
import 'package:teacher_app/features/home/data/models/contact_model.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';

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
  Future<DataState<List<DietaryRestrictionEntity>>>
      getAllDietaryRestrictions() async {
    try {
      final Response response = await childApi.getAllDietaryRestrictions();
      if (response.data == null || response.data['data'] == null) {
        return DataFailed('Response data is null');
      }
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      final List<DietaryRestrictionEntity> restrictionsEntity = [];
      for (var item in list) {
        restrictionsEntity.add(
            DietaryRestrictionModel.fromJson(item as Map<String, dynamic>));
      }
      return DataSuccess(restrictionsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return DataFailed('Unexpected error: $e');
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
  Future<DataState<List<PhysicalRequirementEntity>>>
      getAllPhysicalRequirements() async {
    try {
      final Response response = await childApi.getAllPhysicalRequirements();
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      final List<PhysicalRequirementEntity> requirementsEntity = list
          .map((e) =>
              PhysicalRequirementModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return DataSuccess(requirementsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<ReportableDiseaseEntity>>>
      getAllReportableDiseases() async {
    try {
      final Response response = await childApi.getAllReportableDiseases();
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      final List<ReportableDiseaseEntity> diseasesEntity = list
          .map((e) =>
              ReportableDiseaseModel.fromJson(e as Map<String, dynamic>))
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
      if (response.data == null || response.data['data'] == null) {
        return DataFailed('Response data is null');
      }
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      final List<ImmunizationEntity> immunizationsEntity = [];
      for (var item in list) {
        immunizationsEntity
            .add(ImmunizationModel.fromJson(item as Map<String, dynamic>));
      }
      return DataSuccess(immunizationsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return DataFailed('Unexpected error: $e');
    }
  }

  @override
  Future<DataState<List<AllergyEntity>>> getAllAllergies() async {
    try {
      final Response response = await childApi.getAllAllergies();
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      final List<AllergyEntity> allergiesEntity = list
          .map((e) => AllergyModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return DataSuccess(allergiesEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<ChildEntity>> getChildById({required String childId}) async {
    try {
      final Response response = await childApi.getChildById(childId: childId);
      final Map<String, dynamic> data =
          response.data['data'] as Map<String, dynamic>;
      return DataSuccess(ChildModel.fromJson(data));
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<ChildEntity>> getChildByContactId({
    required String contactId,
  }) async {
    try {
      final Response response =
          await childApi.getChildByContactId(contactId: contactId);
      if (response.data == null || response.data['data'] == null) {
        return DataFailed('Child not found for contactId: $contactId');
      }
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        return DataFailed('Child not found for contactId: $contactId');
      }
      final Map<String, dynamic> data =
          dataList[0] as Map<String, dynamic>;
      return DataSuccess(ChildModel.fromJson(data));
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
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
