import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/notification/domain/entity/notification_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/session/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/features/home/domain/usecase/home_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeUsecase homeUsecase;

  HomeBloc(this.homeUsecase) : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_loadHomeDataEvent);
    on<LoadClassRoomsEvent>(_loadClassRoomsEvent);
    on<LoadContactEvent>(_loadContactEvent);
    on<LoadSessionEvent>(_loadSessionEvent);
    on<CreateSessionEvent>(_createSessionEvent);
    on<UpdateSessionEvent>(_updateSessionEvent);
    on<LoadChildrenEvent>(_loadChildrenEvent);
    on<LoadContactsEvent>(_loadContactsEvent);
    on<LoadDietaryRestrictionsEvent>(_loadDietaryRestrictionsEvent);
    on<LoadMedicationsEvent>(_loadMedicationsEvent);
    on<LoadAttendanceEvent>(_loadAttendanceEvent);
    on<LoadNotificationsEvent>(_loadNotificationsEvent);
    on<LoadEventsEvent>(_loadEventsEvent);
  }

  FutureOr<void> _loadHomeDataEvent(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Load all data in parallel
    if (event.classId != null) {
      add(LoadSessionEvent(event.classId!));
      add(LoadAttendanceEvent(event.classId!));
    }
    if (event.contactId != null) {
      add(LoadContactEvent(event.contactId!));
    }
    add(const LoadClassRoomsEvent());
    add(const LoadChildrenEvent());
    add(const LoadContactsEvent());
    add(const LoadDietaryRestrictionsEvent());
    add(const LoadMedicationsEvent());
    add(const LoadNotificationsEvent());
    add(const LoadEventsEvent());
  }

  FutureOr<void> _loadClassRoomsEvent(
    LoadClassRoomsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingClassRooms: true, classRoomsError: null));

    try {
      final dataState = await homeUsecase.homeRepository.classRoom();

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] LoadClassRoomsSuccess: ${dataState.data?.length ?? 0} classes');
        emit(state.copyWith(
          classRooms: dataState.data ?? [],
          isLoadingClassRooms: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadClassRoomsFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingClassRooms: false,
          classRoomsError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading class rooms: $e');
      emit(state.copyWith(
        isLoadingClassRooms: false,
        classRoomsError: 'خطا در دریافت کلاس‌ها',
      ));
    }
  }

  FutureOr<void> _loadContactEvent(
    LoadContactEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingContact: true, contactError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getContact(id: event.contactId);

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] LoadContactSuccess: ${dataState.data?.id ?? 'unknown'}');
        emit(state.copyWith(
          contact: dataState.data,
          isLoadingContact: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadContactFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingContact: false,
          contactError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading contact: $e');
      emit(state.copyWith(
        isLoadingContact: false,
        contactError: 'خطا در دریافت اطلاعات پروفایل',
      ));
    }
  }

  FutureOr<void> _loadSessionEvent(
    LoadSessionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingSession: true,
      sessionError: null,
    ));

    try {
      final dataState = await homeUsecase.homeRepository.getSessionByClassId(
        classId: event.classId,
      );

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] LoadSessionSuccess: ${dataState.data?.id}');
        emit(state.copyWith(
          session: dataState.data,
          isLoadingSession: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadSessionFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingSession: false,
          sessionError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading session: $e');
      emit(state.copyWith(
        isLoadingSession: false,
        sessionError: 'خطا در دریافت اطلاعات session',
      ));
    }
  }

  FutureOr<void> _createSessionEvent(
    CreateSessionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isProcessingSession: true,
      sessionError: null,
    ));

    try {
      final dataState = await homeUsecase.homeRepository.createSession(
        staffId: event.staffId,
        classId: event.classId,
        startAt: event.startAt,
      );

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] CreateSessionSuccess: ${dataState.data?.id ?? 'unknown'}');
        emit(state.copyWith(
          isProcessingSession: false,
        ));
        // Reload session after creation
        add(LoadSessionEvent(event.classId));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] CreateSessionFailure: ${dataState.error}');
        emit(state.copyWith(
          isProcessingSession: false,
          sessionError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception creating session: $e');
      emit(state.copyWith(
        isProcessingSession: false,
        sessionError: 'خطا در ایجاد session',
      ));
    }
  }

  FutureOr<void> _updateSessionEvent(
    UpdateSessionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isProcessingSession: true,
      sessionError: null,
    ));

    try {
      final dataState = await homeUsecase.homeRepository.updateSession(
        sessionId: event.sessionId,
        endAt: event.endAt,
      );

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] UpdateSessionSuccess: ${dataState.data?.id ?? 'unknown'}');
        emit(state.copyWith(
          isProcessingSession: false,
        ));
        // Reload session after update
        add(LoadSessionEvent(event.classId));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] UpdateSessionFailure: ${dataState.error}');
        emit(state.copyWith(
          isProcessingSession: false,
          sessionError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception updating session: $e');
      emit(state.copyWith(
        isProcessingSession: false,
        sessionError: 'خطا در به‌روزرسانی session',
      ));
    }
  }

  FutureOr<void> _loadChildrenEvent(
    LoadChildrenEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingChildren: true, childrenError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getAllChildren();

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] LoadChildrenSuccess: ${dataState.data?.length ?? 0} children');
        emit(state.copyWith(
          children: dataState.data ?? [],
          isLoadingChildren: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadChildrenFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingChildren: false,
          childrenError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading children: $e');
      emit(state.copyWith(
        isLoadingChildren: false,
        childrenError: 'خطا در دریافت اطلاعات بچه‌ها',
      ));
    }
  }

  FutureOr<void> _loadContactsEvent(
    LoadContactsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingContacts: true, contactsError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getAllContacts();

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] LoadContactsSuccess: ${dataState.data?.length ?? 0} contacts');
        emit(state.copyWith(
          contacts: dataState.data ?? [],
          isLoadingContacts: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadContactsFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingContacts: false,
          contactsError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading contacts: $e');
      emit(state.copyWith(
        isLoadingContacts: false,
        contactsError: 'خطا در دریافت اطلاعات Contacts',
      ));
    }
  }

  FutureOr<void> _loadDietaryRestrictionsEvent(
    LoadDietaryRestrictionsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingDietaryRestrictions: true,
      dietaryRestrictionsError: null,
    ));

    try {
      final dataState = await homeUsecase.homeRepository.getAllDietaryRestrictions();

      if (dataState is DataSuccess) {
        debugPrint(
            '[HOME_DEBUG] LoadDietaryRestrictionsSuccess: ${dataState.data?.length ?? 0} restrictions');
        emit(state.copyWith(
          dietaryRestrictions: dataState.data ?? [],
          isLoadingDietaryRestrictions: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadDietaryRestrictionsFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingDietaryRestrictions: false,
          dietaryRestrictionsError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading dietary restrictions: $e');
      emit(state.copyWith(
        isLoadingDietaryRestrictions: false,
        dietaryRestrictionsError: 'خطا در دریافت محدودیت‌های غذایی',
      ));
    }
  }

  FutureOr<void> _loadMedicationsEvent(
    LoadMedicationsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingMedications: true, medicationsError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getAllMedications();

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] LoadMedicationsSuccess: ${dataState.data?.length ?? 0} medications');
        emit(state.copyWith(
          medications: dataState.data ?? [],
          isLoadingMedications: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadMedicationsFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingMedications: false,
          medicationsError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading medications: $e');
      emit(state.copyWith(
        isLoadingMedications: false,
        medicationsError: 'خطا در دریافت اطلاعات داروها',
      ));
    }
  }

  FutureOr<void> _loadAttendanceEvent(
    LoadAttendanceEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingAttendance: true, attendanceError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getAttendanceByClassId(
        classId: event.classId,
      );

      if (dataState is DataSuccess) {
        debugPrint(
            '[HOME_DEBUG] LoadAttendanceSuccess: ${dataState.data?.length ?? 0} attendance items');
        emit(state.copyWith(
          attendanceList: dataState.data ?? [],
          isLoadingAttendance: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadAttendanceFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingAttendance: false,
          attendanceError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading attendance: $e');
      emit(state.copyWith(
        isLoadingAttendance: false,
        attendanceError: 'خطا در دریافت اطلاعات attendance',
      ));
    }
  }

  FutureOr<void> _loadNotificationsEvent(
    LoadNotificationsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingNotifications: true, notificationsError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getAllNotifications();

      if (dataState is DataSuccess) {
        debugPrint(
            '[HOME_DEBUG] LoadNotificationsSuccess: ${dataState.data?.length ?? 0} notifications');
        emit(state.copyWith(
          notifications: dataState.data ?? [],
          isLoadingNotifications: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadNotificationsFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingNotifications: false,
          notificationsError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading notifications: $e');
      emit(state.copyWith(
        isLoadingNotifications: false,
        notificationsError: 'خطا در دریافت اطلاعات نوتیفیکیشن‌ها',
      ));
    }
  }

  FutureOr<void> _loadEventsEvent(
    LoadEventsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingEvents: true, eventsError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getAllEvents();

      if (dataState is DataSuccess) {
        debugPrint('[HOME_DEBUG] LoadEventsSuccess: ${dataState.data?.length ?? 0} events');
        emit(state.copyWith(
          events: dataState.data ?? [],
          isLoadingEvents: false,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[HOME_DEBUG] LoadEventsFailure: ${dataState.error}');
        emit(state.copyWith(
          isLoadingEvents: false,
          eventsError: dataState.error!,
        ));
      }
    } catch (e) {
      debugPrint('[HOME_DEBUG] Exception loading events: $e');
      emit(state.copyWith(
        isLoadingEvents: false,
        eventsError: 'خطا در دریافت اطلاعات رویدادها',
      ));
    }
  }
}

