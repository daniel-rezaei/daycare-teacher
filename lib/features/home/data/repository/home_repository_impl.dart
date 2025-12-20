import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/attendance/data/models/attendance_child_model/attendance_child_model.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/auth/data/models/class_room_model/class_room_model.dart';
import 'package:teacher_app/features/auth/data/models/staff_class_model/staff_class_model.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/child/data/models/child_model/child_model.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/dietary_restriction/data/models/dietary_restriction_model/dietary_restriction_model.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/event/data/models/event_model/event_model.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
import 'package:teacher_app/features/home/data/data_source/home_api.dart';
import 'package:teacher_app/features/home/domain/repository/home_repository.dart';
import 'package:teacher_app/features/medication/data/models/medication_model/medication_model.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/notification/data/models/notification_model/notification_model.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/profile/data/models/contact_model/contact_model.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/session/data/models/staff_class_session_model/staff_class_session_model.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';

@Singleton(as: HomeRepository, env: [Env.prod])
class HomeRepositoryImpl extends HomeRepository {
  final HomeApi homeApi;

  HomeRepositoryImpl(this.homeApi);

  // ========== Auth Methods ==========
  @override
  Future<DataState<List<ClassRoomEntity>>> classRoom() async {
    try {
      final response = await homeApi.classRoom();
      final List<dynamic> list = (response as Response).data['data'] as List<dynamic>;
      final List<ClassRoomEntity> classRoomsEntity = list
          .map((e) => ClassRoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return DataSuccess(classRoomsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<StaffClassEntity>>> staffClass({required String classId}) async {
    try {
      final response = await homeApi.staffClass(classId: classId);
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
  Future<DataState<String>> getClassIdByContactId({required String contactId}) async {
    try {
      final response = await homeApi.getClassIdByContactId(contactId: contactId);
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        return DataFailed('کلاسی برای این کاربر یافت نشد');
      }
      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      final String? classId = data['class_id'] as String?;
      if (classId == null || classId.isEmpty) {
        return DataFailed('کلاس ID یافت نشد');
      }
      return DataSuccess(classId);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<Map<String, String>>> getContactIdAndClassIdByEmail({required String email}) async {
    try {
      final response = await homeApi.getContactIdAndClassIdByEmail(email: email);
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        return DataFailed('کاربری با این ایمیل یافت نشد');
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
        return DataFailed('کلاس ID یافت نشد');
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

  // ========== Profile Methods ==========
  @override
  Future<DataState<ContactEntity>> getContact({required String id}) async {
    try {
      final response = await homeApi.getContact(id: id);
      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final ContactEntity contactEntity = ContactModel.fromJson(data);
      return DataSuccess(contactEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<List<ContactEntity>>> getAllContacts() async {
    try {
      final response = await homeApi.getAllContacts();
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      final List<ContactEntity> contactsEntity = list
          .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return DataSuccess(contactsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ========== Session Methods ==========
  @override
  Future<DataState<StaffClassSessionEntity?>> getSessionByClassId({required String classId}) async {
    try {
      final response = await homeApi.getSessionByClassId(classId: classId);
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        return DataSuccess(null);
      }
      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      final StaffClassSessionEntity sessionEntity = StaffClassSessionModel.fromJson(data);
      return DataSuccess(sessionEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<StaffClassSessionEntity>> createSession({
    required String staffId,
    required String classId,
    required String startAt,
  }) async {
    try {
      final response = await homeApi.createSession(
        staffId: staffId,
        classId: classId,
        startAt: startAt,
      );
      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final StaffClassSessionEntity sessionEntity = StaffClassSessionModel.fromJson(data);
      return DataSuccess(sessionEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<StaffClassSessionEntity>> updateSession({
    required String sessionId,
    required String endAt,
  }) async {
    try {
      final response = await homeApi.updateSession(
        sessionId: sessionId,
        endAt: endAt,
      );
      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final StaffClassSessionEntity sessionEntity = StaffClassSessionModel.fromJson(data);
      return DataSuccess(sessionEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ========== Child Methods ==========
  @override
  Future<DataState<List<ChildEntity>>> getAllChildren() async {
    try {
      final response = await homeApi.getAllChildren();
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
  Future<DataState<List<DietaryRestrictionEntity>>> getAllDietaryRestrictions() async {
    try {
      final response = await homeApi.getAllDietaryRestrictions();
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
      final response = await homeApi.getAllMedications();
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
  Future<DataState<ChildEntity>> getChildById({required String childId}) async {
    try {
      final response = await homeApi.getChildById(childId: childId);
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
      final response = await homeApi.getChildByContactId(contactId: contactId);
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        return DataFailed('Child not found for contactId: $contactId');
      }
      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      final ChildEntity childEntity = ChildModel.fromJson(data);
      return DataSuccess(childEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ========== Attendance Methods ==========
  @override
  Future<DataState<List<AttendanceChildEntity>>> getAttendanceByClassId({
    required String classId,
    String? childId,
  }) async {
    try {
      final response = await homeApi.getAttendanceByClassId(
        classId: classId,
        childId: childId,
      );
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<AttendanceChildEntity> attendanceList = dataList
          .map((data) => AttendanceChildModel.fromJson(data as Map<String, dynamic>))
          .toList();
      return DataSuccess(attendanceList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<AttendanceChildEntity>> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  }) async {
    try {
      final response = await homeApi.createAttendance(
        childId: childId,
        classId: classId,
        checkInAt: checkInAt,
        staffId: staffId,
      );
      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final AttendanceChildEntity attendanceEntity = AttendanceChildModel.fromJson(data);
      return DataSuccess(attendanceEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<DataState<AttendanceChildEntity>> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo,
    String? checkoutPickupContactId,
    String? checkoutPickupContactType,
  }) async {
    try {
      // ابتدا attendance موجود را دریافت می‌کنیم
      final getResponse = await homeApi.getAttendanceById(attendanceId: attendanceId);
      final Map<String, dynamic> existingData = getResponse.data['data'] as Map<String, dynamic>;
      final AttendanceChildEntity existingAttendance = AttendanceChildModel.fromJson(existingData);

      // سپس با POST و همه فیلدها به‌روزرسانی می‌کنیم
      final response = await homeApi.updateAttendance(
        attendanceId: attendanceId,
        checkOutAt: checkOutAt,
        notes: notes,
        photo: photo,
        checkoutPickupContactId: checkoutPickupContactId,
        checkoutPickupContactType: checkoutPickupContactType,
        childId: existingAttendance.childId,
        classId: existingAttendance.classId,
        checkInAt: existingAttendance.checkInAt,
        staffId: existingAttendance.staffId,
        checkInMethod: existingAttendance.checkInMethod,
      );

      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      final AttendanceChildEntity attendanceEntity = AttendanceChildModel.fromJson(data);
      return DataSuccess(attendanceEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ========== Notification Methods ==========
  @override
  Future<DataState<List<NotificationEntity>>> getAllNotifications() async {
    try {
      final response = await homeApi.getAllNotifications();
      final List<dynamic> dataList = response.data['data'] as List<dynamic>;
      final List<NotificationEntity> notificationList = dataList
          .map((data) => NotificationModel.fromJson(data as Map<String, dynamic>))
          .toList();
      return DataSuccess(notificationList);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ========== Event Methods ==========
  @override
  Future<DataState<List<EventEntity>>> getAllEvents() async {
    try {
      final response = await homeApi.getAllEvents();
      final List<dynamic> list = response.data['data'] as List<dynamic>;
      final List<EventEntity> eventsEntity = list
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return DataSuccess(eventsEntity);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ========== Error Handling ==========
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
    } else if (e.response!.statusCode != null && e.response!.statusCode! >= 500) {
      return DataFailed<T>(
        'The server is currently under maintenance. Please be patient.',
      );
    } else {
      String errorMessage = 'خطا در دریافت اطلاعات';
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ??
            e.response?.statusMessage ??
            'خطا در ارتباط با سرور';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'زمان اتصال به سرور به پایان رسید';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'خطا در اتصال به سرور';
      }
      return DataFailed<T>(errorMessage);
    }
  }
}

