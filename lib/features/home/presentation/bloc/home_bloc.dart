import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/reportable_disease_entity.dart';
import 'package:teacher_app/features/event/domain/entity/event_entity.dart';
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
    final repo = homeUsecase.homeRepository;

    // فاز ۱: داده‌های ضروری برای اولین نمایش داشبورد — یک بار و موازی
    emit(state.copyWith(
      isLoadingClassRooms: true,
      isLoadingContact: event.contactId != null,
      isLoadingChildren: true,
      isLoadingContacts: true,
      classRoomsError: null,
      contactError: null,
      childrenError: null,
      contactsError: null,
    ));

    final classRoomsFuture = repo.classRoom();
    final childrenFuture = repo.getAllChildren();
    final contactsFuture = repo.getAllContacts();
    final contactFuture = event.contactId != null
        ? repo.getContact(id: event.contactId!)
        : null;

    final results = await Future.wait([
      classRoomsFuture,
      childrenFuture,
      contactsFuture,
      if (contactFuture != null) contactFuture,
    ]);

    List<ClassRoomEntity>? classRooms;
    String? classRoomsError;
    List<ChildEntity>? children;
    String? childrenError;
    List<ContactEntity>? contacts;
    String? contactsError;
    ContactEntity? contact;
    String? contactError;

    final classRoomsState = results[0] as DataState<List<ClassRoomEntity>>;
    if (classRoomsState is DataSuccess) {
      classRooms = classRoomsState.data ?? [];
    } else if (classRoomsState is DataFailed) {
      classRoomsError = classRoomsState.error;
    }

    final childrenState = results[1] as DataState<List<ChildEntity>>;
    if (childrenState is DataSuccess) {
      children = childrenState.data ?? [];
    } else if (childrenState is DataFailed) {
      childrenError = childrenState.error;
    }

    final contactsState = results[2] as DataState<List<ContactEntity>>;
    if (contactsState is DataSuccess) {
      contacts = contactsState.data ?? [];
    } else if (contactsState is DataFailed) {
      contactsError = contactsState.error;
    }

    if (contactFuture != null) {
      final contactState = results[3] as DataState<ContactEntity>;
      if (contactState is DataSuccess) {
        contact = contactState.data;
      } else if (contactState is DataFailed) {
        contactError = contactState.error;
      }
    } else {
      contactError = '';
    }

    emit(state.copyWith(
      classRooms: classRooms,
      classRoomsError: classRoomsError,
      isLoadingClassRooms: false,
      children: children,
      childrenError: childrenError,
      isLoadingChildren: false,
      contacts: contacts,
      contactsError: contactsError,
      isLoadingContacts: false,
      contact: contact,
      contactError: contactError,
      isLoadingContact: false,
    ));

    // فاز ۲: session، attendance، notifications، events — موازی
    final phase2Futures = <Future>[
      repo.getAllNotifications(),
      repo.getAllEvents(),
    ];
    if (event.classId != null) {
      phase2Futures.insertAll(
        0,
        [
          repo.getSessionByClassId(classId: event.classId!),
          repo.getAttendanceByClassId(classId: event.classId!),
        ],
      );
    }

    final phase2Results = await Future.wait(phase2Futures);
    int idx = 0;

    if (event.classId != null) {
      final sessionState =
          phase2Results[idx++] as DataState<StaffClassSessionEntity?>;
      if (sessionState is DataSuccess) {
        emit(state.copyWith(
          session: sessionState.data,
          isLoadingSession: false,
        ));
      } else if (sessionState is DataFailed) {
        emit(state.copyWith(
          sessionError: sessionState.error,
          isLoadingSession: false,
        ));
      }

      final attendanceState =
          phase2Results[idx++] as DataState<List<AttendanceChildEntity>>;
      if (attendanceState is DataSuccess) {
        emit(state.copyWith(
          attendanceList: attendanceState.data ?? [],
          isLoadingAttendance: false,
        ));
      } else if (attendanceState is DataFailed) {
        emit(state.copyWith(
          attendanceError: attendanceState.error,
          isLoadingAttendance: false,
        ));
      }
    }

    final notificationsState =
        phase2Results[idx++] as DataState<List<NotificationEntity>>;
    if (notificationsState is DataSuccess) {
      emit(state.copyWith(
        notifications: notificationsState.data ?? [],
        isLoadingNotifications: false,
      ));
    } else if (notificationsState is DataFailed) {
      emit(state.copyWith(
        notificationsError: notificationsState.error,
        isLoadingNotifications: false,
      ));
    }

    final eventsState = phase2Results[idx] as DataState<List<EventEntity>>;
    if (eventsState is DataSuccess) {
      emit(state.copyWith(
        events: eventsState.data ?? [],
        isLoadingEvents: false,
      ));
    } else if (eventsState is DataFailed) {
      emit(state.copyWith(
        eventsError: eventsState.error,
        isLoadingEvents: false,
      ));
    }

    // فاز ۳: dietary، medications، physical، reportable — موازی، بعد از نمایش داشبورد
    final phase3Results = await Future.wait([
      repo.getAllDietaryRestrictions(),
      repo.getAllMedications(),
      repo.getAllPhysicalRequirements(),
      repo.getAllReportableDiseases(),
    ]);

    final dietaryState =
        phase3Results[0] as DataState<List<DietaryRestrictionEntity>>;
    if (dietaryState is DataSuccess) {
      emit(state.copyWith(
        dietaryRestrictions: dietaryState.data ?? [],
        isLoadingDietaryRestrictions: false,
      ));
    } else if (dietaryState is DataFailed) {
      emit(state.copyWith(
        dietaryRestrictionsError: dietaryState.error,
        isLoadingDietaryRestrictions: false,
      ));
    }

    final medicationsState =
        phase3Results[1] as DataState<List<MedicationEntity>>;
    if (medicationsState is DataSuccess) {
      emit(state.copyWith(
        medications: medicationsState.data ?? [],
        isLoadingMedications: false,
      ));
    } else if (medicationsState is DataFailed) {
      emit(state.copyWith(
        medicationsError: medicationsState.error,
        isLoadingMedications: false,
      ));
    }

    final physicalState =
        phase3Results[2] as DataState<List<PhysicalRequirementEntity>>;
    if (physicalState is DataSuccess) {
      emit(state.copyWith(
        physicalRequirements: physicalState.data ?? [],
        isLoadingPhysicalRequirements: false,
      ));
    } else if (physicalState is DataFailed) {
      emit(state.copyWith(
        physicalRequirementsError: physicalState.error,
        isLoadingPhysicalRequirements: false,
      ));
    }

    final reportableState =
        phase3Results[3] as DataState<List<ReportableDiseaseEntity>>;
    if (reportableState is DataSuccess) {
      emit(state.copyWith(
        reportableDiseases: reportableState.data ?? [],
        isLoadingReportableDiseases: false,
      ));
    } else if (reportableState is DataFailed) {
      emit(state.copyWith(
        reportableDiseasesError: reportableState.error,
        isLoadingReportableDiseases: false,
      ));
    }
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
