import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/reportable_disease/domain/entity/reportable_disease_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';

abstract class HomeRepository {
  // ========== Auth Methods ==========
  Future<DataState<List<ClassRoomEntity>>> classRoom();
  Future<DataState<List<StaffClassEntity>>> staffClass({required String classId});
  Future<DataState<String>> getClassIdByContactId({required String contactId});
  Future<DataState<Map<String, String>>> getContactIdAndClassIdByEmail({required String email});

  // ========== Profile Methods ==========
  Future<DataState<ContactEntity>> getContact({required String id});
  Future<DataState<List<ContactEntity>>> getAllContacts();

  // ========== Session Methods ==========
  Future<DataState<StaffClassSessionEntity?>> getSessionByClassId({required String classId});
  Future<DataState<StaffClassSessionEntity>> createSession({
    required String staffId,
    required String classId,
    required String startAt,
  });
  Future<DataState<StaffClassSessionEntity>> updateSession({
    required String sessionId,
    required String endAt,
  });

  // ========== Child Methods ==========
  Future<DataState<List<ChildEntity>>> getAllChildren();
  Future<DataState<List<DietaryRestrictionEntity>>> getAllDietaryRestrictions();
  Future<DataState<List<MedicationEntity>>> getAllMedications();
  Future<DataState<List<PhysicalRequirementEntity>>> getAllPhysicalRequirements();
  Future<DataState<List<ReportableDiseaseEntity>>> getAllReportableDiseases();
  Future<DataState<ChildEntity>> getChildById({required String childId});
  Future<DataState<ChildEntity>> getChildByContactId({required String contactId});

  // ========== Attendance Methods ==========
  Future<DataState<List<AttendanceChildEntity>>> getAttendanceByClassId({
    required String classId,
    String? childId,
  });
  Future<DataState<AttendanceChildEntity>> createAttendance({
    required String childId,
    required String classId,
    required String checkInAt,
    String? staffId,
  });
  // DOMAIN LOCKDOWN: Checkout API accepts ONLY pickup_authorization_id
  // No contact/guardian/pickup creation allowed from checkout flow
  Future<DataState<AttendanceChildEntity>> updateAttendance({
    required String attendanceId,
    required String checkOutAt,
    String? notes,
    String? photo, // String of file ID (first file ID if multiple)
    String? pickupAuthorizationId, // ONLY accepts existing PickupAuthorization ID
  });

  // ========== Notification Methods ==========
  Future<DataState<List<NotificationEntity>>> getAllNotifications();

  // ========== Event Methods ==========
  Future<DataState<List<EventEntity>>> getAllEvents();
}

