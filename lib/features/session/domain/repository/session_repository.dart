import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';

abstract class SessionRepository {
  // دریافت session بر اساس class_id
  Future<DataState<StaffClassSessionEntity?>> getSessionByClassId({
    required String classId,
  });

  // ایجاد session جدید (check-in)
  Future<DataState<StaffClassSessionEntity>> createSession({
    required String staffId,
    required String classId,
    required String startAt,
  });

  // به‌روزرسانی session موجود (check-out)
  Future<DataState<StaffClassSessionEntity>> updateSession({
    required String sessionId,
    required String endAt,
  });
}


