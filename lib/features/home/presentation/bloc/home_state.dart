part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  // Class rooms
  final List<ClassRoomEntity>? classRooms;
  final bool isLoadingClassRooms;
  final String? classRoomsError;

  // Contact/Profile
  final ContactEntity? contact;
  final bool isLoadingContact;
  final String? contactError;

  // Session
  final StaffClassSessionEntity? session;
  final bool isLoadingSession;
  final bool isProcessingSession;
  final String? sessionError;

  // Children
  final List<ChildEntity>? children;
  final bool isLoadingChildren;
  final String? childrenError;

  // Contacts
  final List<ContactEntity>? contacts;
  final bool isLoadingContacts;
  final String? contactsError;

  // Dietary restrictions
  final List<DietaryRestrictionEntity>? dietaryRestrictions;
  final bool isLoadingDietaryRestrictions;
  final String? dietaryRestrictionsError;

  // Medications
  final List<MedicationEntity>? medications;
  final bool isLoadingMedications;
  final String? medicationsError;

  // Attendance
  final List<AttendanceChildEntity>? attendanceList;
  final bool isLoadingAttendance;
  final String? attendanceError;

  // Notifications
  final List<NotificationEntity>? notifications;
  final bool isLoadingNotifications;
  final String? notificationsError;

  // Events
  final List<EventEntity>? events;
  final bool isLoadingEvents;
  final String? eventsError;

  const HomeState({
    this.classRooms,
    this.isLoadingClassRooms = false,
    this.classRoomsError,
    this.contact,
    this.isLoadingContact = false,
    this.contactError,
    this.session,
    this.isLoadingSession = false,
    this.isProcessingSession = false,
    this.sessionError,
    this.children,
    this.isLoadingChildren = false,
    this.childrenError,
    this.contacts,
    this.isLoadingContacts = false,
    this.contactsError,
    this.dietaryRestrictions,
    this.isLoadingDietaryRestrictions = false,
    this.dietaryRestrictionsError,
    this.medications,
    this.isLoadingMedications = false,
    this.medicationsError,
    this.attendanceList,
    this.isLoadingAttendance = false,
    this.attendanceError,
    this.notifications,
    this.isLoadingNotifications = false,
    this.notificationsError,
    this.events,
    this.isLoadingEvents = false,
    this.eventsError,
  });

  @override
  List<Object?> get props => [
        classRooms,
        isLoadingClassRooms,
        classRoomsError,
        contact,
        isLoadingContact,
        contactError,
        session,
        isLoadingSession,
        isProcessingSession,
        sessionError,
        children,
        isLoadingChildren,
        childrenError,
        contacts,
        isLoadingContacts,
        contactsError,
        dietaryRestrictions,
        isLoadingDietaryRestrictions,
        dietaryRestrictionsError,
        medications,
        isLoadingMedications,
        medicationsError,
        attendanceList,
        isLoadingAttendance,
        attendanceError,
        notifications,
        isLoadingNotifications,
        notificationsError,
        events,
        isLoadingEvents,
        eventsError,
      ];

  HomeState copyWith({
    List<ClassRoomEntity>? classRooms,
    bool? isLoadingClassRooms,
    String? classRoomsError,
    ContactEntity? contact,
    bool? isLoadingContact,
    String? contactError,
    StaffClassSessionEntity? session,
    bool? isLoadingSession,
    bool? isProcessingSession,
    String? sessionError,
    List<ChildEntity>? children,
    bool? isLoadingChildren,
    String? childrenError,
    List<ContactEntity>? contacts,
    bool? isLoadingContacts,
    String? contactsError,
    List<DietaryRestrictionEntity>? dietaryRestrictions,
    bool? isLoadingDietaryRestrictions,
    String? dietaryRestrictionsError,
    List<MedicationEntity>? medications,
    bool? isLoadingMedications,
    String? medicationsError,
    List<AttendanceChildEntity>? attendanceList,
    bool? isLoadingAttendance,
    String? attendanceError,
    List<NotificationEntity>? notifications,
    bool? isLoadingNotifications,
    String? notificationsError,
    List<EventEntity>? events,
    bool? isLoadingEvents,
    String? eventsError,
  }) {
    return HomeInitial(
      classRooms: classRooms ?? this.classRooms,
      isLoadingClassRooms: isLoadingClassRooms ?? this.isLoadingClassRooms,
      classRoomsError: classRoomsError ?? this.classRoomsError,
      contact: contact ?? this.contact,
      isLoadingContact: isLoadingContact ?? this.isLoadingContact,
      contactError: contactError ?? this.contactError,
      session: session ?? this.session,
      isLoadingSession: isLoadingSession ?? this.isLoadingSession,
      isProcessingSession: isProcessingSession ?? this.isProcessingSession,
      sessionError: sessionError ?? this.sessionError,
      children: children ?? this.children,
      isLoadingChildren: isLoadingChildren ?? this.isLoadingChildren,
      childrenError: childrenError ?? this.childrenError,
      contacts: contacts ?? this.contacts,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
      contactsError: contactsError ?? this.contactsError,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      isLoadingDietaryRestrictions:
          isLoadingDietaryRestrictions ?? this.isLoadingDietaryRestrictions,
      dietaryRestrictionsError:
          dietaryRestrictionsError ?? this.dietaryRestrictionsError,
      medications: medications ?? this.medications,
      isLoadingMedications: isLoadingMedications ?? this.isLoadingMedications,
      medicationsError: medicationsError ?? this.medicationsError,
      attendanceList: attendanceList ?? this.attendanceList,
      isLoadingAttendance: isLoadingAttendance ?? this.isLoadingAttendance,
      attendanceError: attendanceError ?? this.attendanceError,
      notifications: notifications ?? this.notifications,
      isLoadingNotifications: isLoadingNotifications ?? this.isLoadingNotifications,
      notificationsError: notificationsError ?? this.notificationsError,
      events: events ?? this.events,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      eventsError: eventsError ?? this.eventsError,
    );
  }
}

final class HomeInitial extends HomeState {
  const HomeInitial({
    super.classRooms,
    super.isLoadingClassRooms,
    super.classRoomsError,
    super.contact,
    super.isLoadingContact,
    super.contactError,
    super.session,
    super.isLoadingSession,
    super.isProcessingSession,
    super.sessionError,
    super.children,
    super.isLoadingChildren,
    super.childrenError,
    super.contacts,
    super.isLoadingContacts,
    super.contactsError,
    super.dietaryRestrictions,
    super.isLoadingDietaryRestrictions,
    super.dietaryRestrictionsError,
    super.medications,
    super.isLoadingMedications,
    super.medicationsError,
    super.attendanceList,
    super.isLoadingAttendance,
    super.attendanceError,
    super.notifications,
    super.isLoadingNotifications,
    super.notificationsError,
    super.events,
    super.isLoadingEvents,
    super.eventsError,
  });
}

