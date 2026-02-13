import 'dart:async';
import 'package:equatable/equatable.dart';
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
import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/reportable_disease/domain/entity/reportable_disease_entity.dart';
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
    on<LoadPhysicalRequirementsEvent>(_loadPhysicalRequirementsEvent);
    on<LoadReportableDiseasesEvent>(_loadReportableDiseasesEvent);
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
    add(const LoadPhysicalRequirementsEvent());
    add(const LoadReportableDiseasesEvent());
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
        emit(
          state.copyWith(
            classRooms: dataState.data ?? [],
            isLoadingClassRooms: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingClassRooms: false,
            classRoomsError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingClassRooms: false,
          classRoomsError: 'Error retrieving classes',
        ),
      );
    }
  }

  FutureOr<void> _loadContactEvent(
    LoadContactEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingContact: true, contactError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getContact(
        id: event.contactId,
      );

      if (dataState is DataSuccess) {
        emit(state.copyWith(contact: dataState.data, isLoadingContact: false));
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingContact: false,
            contactError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingContact: false,
          contactError: 'Error retrieving profile information',
        ),
      );
    }
  }

  FutureOr<void> _loadSessionEvent(
    LoadSessionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingSession: true, sessionError: null));

    try {
      final dataState = await homeUsecase.homeRepository.getSessionByClassId(
        classId: event.classId,
      );

      if (dataState is DataSuccess) {
        emit(state.copyWith(session: dataState.data, isLoadingSession: false));
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingSession: false,
            sessionError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingSession: false,
          sessionError: 'Error retrieving session information',
        ),
      );
    }
  }

  FutureOr<void> _createSessionEvent(
    CreateSessionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isProcessingSession: true, sessionError: null));

    try {
      final dataState = await homeUsecase.homeRepository.createSession(
        staffId: event.staffId,
        classId: event.classId,
        startAt: event.startAt,
      );

      if (dataState is DataSuccess) {
        emit(state.copyWith(isProcessingSession: false));
        // Reload session after creation
        add(LoadSessionEvent(event.classId));
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isProcessingSession: false,
            sessionError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isProcessingSession: false,
          sessionError: 'Error creating session',
        ),
      );
    }
  }

  FutureOr<void> _updateSessionEvent(
    UpdateSessionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isProcessingSession: true, sessionError: null));

    try {
      final dataState = await homeUsecase.homeRepository.updateSession(
        sessionId: event.sessionId,
        endAt: event.endAt,
      );

      if (dataState is DataSuccess) {
        emit(state.copyWith(isProcessingSession: false));
        // Reload session after update
        add(LoadSessionEvent(event.classId));
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isProcessingSession: false,
            sessionError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isProcessingSession: false,
          sessionError: 'Error updating session',
        ),
      );
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
        emit(
          state.copyWith(
            children: dataState.data ?? [],
            isLoadingChildren: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingChildren: false,
            childrenError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingChildren: false,
          childrenError: 'Error retrieving children information',
        ),
      );
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
        emit(
          state.copyWith(
            contacts: dataState.data ?? [],
            isLoadingContacts: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingContacts: false,
            contactsError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingContacts: false,
          contactsError: 'Error retrieving Contacts information',
        ),
      );
    }
  }

  FutureOr<void> _loadDietaryRestrictionsEvent(
    LoadDietaryRestrictionsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingDietaryRestrictions: true,
        dietaryRestrictionsError: null,
      ),
    );

    try {
      final dataState = await homeUsecase.homeRepository
          .getAllDietaryRestrictions();

      if (dataState is DataSuccess) {
        emit(
          state.copyWith(
            dietaryRestrictions: dataState.data ?? [],
            isLoadingDietaryRestrictions: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingDietaryRestrictions: false,
            dietaryRestrictionsError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingDietaryRestrictions: false,
          dietaryRestrictionsError: 'Error retrieving dietary restrictions',
        ),
      );
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
        emit(
          state.copyWith(
            medications: dataState.data ?? [],
            isLoadingMedications: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingMedications: false,
            medicationsError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMedications: false,
          medicationsError: 'Error retrieving medications information',
        ),
      );
    }
  }

  FutureOr<void> _loadPhysicalRequirementsEvent(
    LoadPhysicalRequirementsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingPhysicalRequirements: true,
        physicalRequirementsError: null,
      ),
    );

    try {
      final dataState = await homeUsecase.homeRepository
          .getAllPhysicalRequirements();

      if (dataState is DataSuccess) {
        emit(
          state.copyWith(
            physicalRequirements: dataState.data ?? [],
            isLoadingPhysicalRequirements: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingPhysicalRequirements: false,
            physicalRequirementsError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingPhysicalRequirements: false,
          physicalRequirementsError:
              'Error retrieving physical requirements information',
        ),
      );
    }
  }

  FutureOr<void> _loadReportableDiseasesEvent(
    LoadReportableDiseasesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingReportableDiseases: true,
        reportableDiseasesError: null,
      ),
    );

    try {
      final dataState = await homeUsecase.homeRepository
          .getAllReportableDiseases();

      if (dataState is DataSuccess) {
        emit(
          state.copyWith(
            reportableDiseases: dataState.data ?? [],
            isLoadingReportableDiseases: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingReportableDiseases: false,
            reportableDiseasesError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingReportableDiseases: false,
          reportableDiseasesError:
              'Error retrieving reportable diseases information',
        ),
      );
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
        emit(
          state.copyWith(
            attendanceList: dataState.data ?? [],
            isLoadingAttendance: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingAttendance: false,
            attendanceError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingAttendance: false,
          attendanceError: 'Error retrieving attendance information',
        ),
      );
    }
  }

  FutureOr<void> _loadNotificationsEvent(
    LoadNotificationsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(isLoadingNotifications: true, notificationsError: null),
    );

    try {
      final dataState = await homeUsecase.homeRepository.getAllNotifications();

      if (dataState is DataSuccess) {
        emit(
          state.copyWith(
            notifications: dataState.data ?? [],
            isLoadingNotifications: false,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(
            isLoadingNotifications: false,
            notificationsError: dataState.error!,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingNotifications: false,
          notificationsError: 'Error retrieving notifications information',
        ),
      );
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
        emit(
          state.copyWith(events: dataState.data ?? [], isLoadingEvents: false),
        );
      } else if (dataState is DataFailed) {
        emit(
          state.copyWith(isLoadingEvents: false, eventsError: dataState.error!),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingEvents: false,
          eventsError: 'Error retrieving events information',
        ),
      );
    }
  }
}
