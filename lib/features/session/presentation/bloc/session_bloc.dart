import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/features/session/domain/usecase/session_usecase.dart';

part 'session_event.dart';
part 'session_state.dart';

@injectable
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionUsecase sessionUsecase;
  SessionBloc(this.sessionUsecase) : super(SessionInitial()) {
    on<GetSessionByClassIdEvent>(_getSessionByClassIdEvent);
    on<CreateSessionEvent>(_createSessionEvent);
    on<UpdateSessionEvent>(_updateSessionEvent);
  }

  FutureOr<void> _getSessionByClassIdEvent(
    GetSessionByClassIdEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(GetSessionByClassIdLoading());

    try {
      DataState dataState = await sessionUsecase.getSessionByClassId(
        classId: event.classId,
      );

      if (dataState is DataSuccess) {
        debugPrint(
            '[SESSION_DEBUG] GetSessionByClassIdSuccess: ${dataState.data?.id}');
        emit(GetSessionByClassIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint('[SESSION_DEBUG] GetSessionByClassIdFailure: ${dataState.error}');
        emit(GetSessionByClassIdFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[SESSION_DEBUG] Exception getting session: $e');
      emit(GetSessionByClassIdFailure('خطا در دریافت اطلاعات session'));
    }
  }

  FutureOr<void> _createSessionEvent(
    CreateSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(CreateSessionLoading());

    try {
      DataState dataState = await sessionUsecase.createSession(
        staffId: event.staffId,
        classId: event.classId,
        startAt: event.startAt,
      );

      if (dataState is DataSuccess) {
        debugPrint('[SESSION_DEBUG] CreateSessionSuccess: ${dataState.data.id}');
        emit(CreateSessionSuccess(dataState.data));
        // بعد از ایجاد session، session جدید را دریافت می‌کنیم
        add(GetSessionByClassIdEvent(classId: event.classId));
      } else if (dataState is DataFailed) {
        debugPrint('[SESSION_DEBUG] CreateSessionFailure: ${dataState.error}');
        emit(CreateSessionFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[SESSION_DEBUG] Exception creating session: $e');
      emit(CreateSessionFailure('خطا در ایجاد session'));
    }
  }

  FutureOr<void> _updateSessionEvent(
    UpdateSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(UpdateSessionLoading());

    try {
      DataState dataState = await sessionUsecase.updateSession(
        sessionId: event.sessionId,
        endAt: event.endAt,
      );

      if (dataState is DataSuccess) {
        debugPrint('[SESSION_DEBUG] UpdateSessionSuccess: ${dataState.data.id}');
        emit(UpdateSessionSuccess(dataState.data));
        // بعد از update session، session جدید را دریافت می‌کنیم
        add(GetSessionByClassIdEvent(classId: event.classId));
      } else if (dataState is DataFailed) {
        debugPrint('[SESSION_DEBUG] UpdateSessionFailure: ${dataState.error}');
        emit(UpdateSessionFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[SESSION_DEBUG] Exception updating session: $e');
      emit(UpdateSessionFailure('خطا در به‌روزرسانی session'));
    }
  }
}


