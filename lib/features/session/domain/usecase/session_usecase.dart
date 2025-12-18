import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/features/session/domain/repository/session_repository.dart';

@singleton
class SessionUsecase {
  final SessionRepository sessionRepository;

  SessionUsecase(this.sessionRepository);

  // دریافت session بر اساس class_id
  Future<DataState<StaffClassSessionEntity?>> getSessionByClassId({
    required String classId,
  }) async {
    return await sessionRepository.getSessionByClassId(classId: classId);
  }

  // ایجاد session جدید (check-in)
  Future<DataState<StaffClassSessionEntity>> createSession({
    required String staffId,
    required String classId,
    required String startAt,
  }) async {
    return await sessionRepository.createSession(
      staffId: staffId,
      classId: classId,
      startAt: startAt,
    );
  }

  // به‌روزرسانی session موجود (check-out)
  Future<DataState<StaffClassSessionEntity>> updateSession({
    required String sessionId,
    required String endAt,
  }) async {
    return await sessionRepository.updateSession(
      sessionId: sessionId,
      endAt: endAt,
    );
  }
}


