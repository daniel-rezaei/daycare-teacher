import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/auth/data/data_source/auth_api.dart';
import 'package:teacher_app/features/auth/data/models/class_room_model/class_room_model.dart';
import 'package:teacher_app/features/auth/data/models/staff_class_model/staff_class_model.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/domain/repository/auth_repository.dart';

@Singleton(as: AuthRepository, env: [Env.prod])
class AuthRepositoryImpl extends AuthRepository {
  final AuthApi authApi;

  AuthRepositoryImpl(this.authApi);

  @override
  Future<DataState<List<ClassRoomEntity>>> classRoom() async {
    try {
      final Response response = await authApi.classRoom();

      // اطمینان از اینکه 'data' در response وجود دارد و یک لیست است
      final List<dynamic> list = response.data['data'] as List<dynamic>;

      final List<ClassRoomEntity> classRoomsEntity = list
          .map((e) => ClassRoomModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return DataSuccess(classRoomsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<StaffClassEntity>>> staffClass({
    required String classId,
  }) async {
    try {
      final Response response = await authApi.staffClass(classId: classId);

      final List list = response.data['data'] as List;

      final List<StaffClassEntity> staffClassEntity = list
          .map((e) => StaffClassModel.fromJson(e))
          .toList();

      return DataSuccess(staffClassEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<String>> getClassIdByContactId({
    required String contactId,
  }) async {
    try {
      final Response response = await authApi.getClassIdByContactId(
        contactId: contactId,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;

      if (dataList.isEmpty) {
        return DataFailed('No class found for this user');
      }

      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      final String? classId = data['class_id'] as String?;

      if (classId == null || classId.isEmpty) {
        return DataFailed('Class ID not found');
      }

      return DataSuccess(classId);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<Map<String, String>>> getContactIdAndClassIdByEmail({
    required String email,
  }) async {
    try {
      final Response response = await authApi.getContactIdAndClassIdByEmail(
        email: email,
      );

      final List<dynamic> dataList = response.data['data'] as List<dynamic>;

      if (dataList.isEmpty) {
        return DataFailed('No user found with this email');
      }

      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      final String? classId = data['class_id'] as String?;
      
      final Map<String, dynamic>? staffId = data['staff_id'] as Map<String, dynamic>?;
      final String? staffIdValue = staffId?['id'] as String?;
      final Map<String, dynamic>? contactIdObj = staffId?['contact_id'] as Map<String, dynamic>?;
      final String? contactId = contactIdObj?['id'] as String?;

      if (contactId == null || contactId.isEmpty) {
        return DataFailed('Contact ID یافت نشد');
      }

      if (classId == null || classId.isEmpty) {
        return DataFailed('Class ID not found');
      }

      return DataSuccess({
        'contact_id': contactId,
        'class_id': classId,
        'staff_id': staffIdValue ?? '',
      });
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  DataFailed<T> _handleDioError<T>(DioException e) {
    if (e.response == null) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return DataFailed<T>(
          'It seems your internet connection is active, but the server response is taking too long.',
        );
      } else {
        return DataFailed<T>('Please check your internet connection.');
      }
    } else if (e.response!.statusCode == 403) {
      return DataFailed<T>('Access to this section is restricted for you.');
    } else if (e.response!.statusCode != null &&
        e.response!.statusCode! >= 500) {
      return DataFailed<T>(
        'The server is currently under maintenance. Please be patient.',
      );
    } else {
      return DataFailed<T>('An unknown error occurred.');
    }
  }
}
