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

  // Physical Requirements
  final List<PhysicalRequirementEntity>? physicalRequirements;
  final bool isLoadingPhysicalRequirements;
  final String? physicalRequirementsError;

  // Reportable Diseases
  final List<ReportableDiseaseEntity>? reportableDiseases;
  final bool isLoadingReportableDiseases;
  final String? reportableDiseasesError;

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
    this.physicalRequirements,
    this.isLoadingPhysicalRequirements = false,
    this.physicalRequirementsError,
    this.reportableDiseases,
    this.isLoadingReportableDiseases = false,
    this.reportableDiseasesError,
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

  /// بررسی اینکه آیا داده‌های اصلی در حال لود شدن هستند
  /// این متد فقط بررسی می‌کند که آیا در حال حاضر loading فعال است یا نه
  bool get isInitialLoading {
    return isLoadingClassRooms ||
        isLoadingContact ||
        isLoadingSession ||
        isLoadingChildren ||
        isLoadingContacts ||
        isLoadingAttendance ||
        isLoadingNotifications ||
        isLoadingEvents ||
        isLoadingDietaryRestrictions ||
        isLoadingMedications ||
        isLoadingPhysicalRequirements ||
        isLoadingReportableDiseases;
  }

  /// بررسی اینکه آیا همه داده‌های اصلی لود شده‌اند
  /// این متد بررسی می‌کند که آیا همه درخواست‌ها به پایان رسیده‌اند (موفق یا ناموفق)
  /// اگر هیچ loading فعالی وجود نداشته باشد، یعنی همه درخواست‌ها به پایان رسیده‌اند
  bool get isInitialDataLoaded {
    return !isInitialLoading;
  }

  /// بررسی اینکه آیا داده‌های ضروری حداقل یک بار لود شده‌اند
  /// فقط classRooms، children، contacts لازم است تا داشبورد نمایش داده شود؛
  /// contact می‌تواند بعداً با اسکلتون نمایش داده شود.
  bool get hasLoadedInitialDataOnce {
    return (classRooms != null || classRoomsError != null) &&
        (children != null || childrenError != null) &&
        (contacts != null || contactsError != null);
  }

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
        physicalRequirements,
        isLoadingPhysicalRequirements,
        physicalRequirementsError,
        reportableDiseases,
        isLoadingReportableDiseases,
        reportableDiseasesError,
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
    List<PhysicalRequirementEntity>? physicalRequirements,
    bool? isLoadingPhysicalRequirements,
    String? physicalRequirementsError,
    List<ReportableDiseaseEntity>? reportableDiseases,
    bool? isLoadingReportableDiseases,
    String? reportableDiseasesError,
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
      physicalRequirements: physicalRequirements ?? this.physicalRequirements,
      isLoadingPhysicalRequirements: isLoadingPhysicalRequirements ?? this.isLoadingPhysicalRequirements,
      physicalRequirementsError: physicalRequirementsError ?? this.physicalRequirementsError,
      reportableDiseases: reportableDiseases ?? this.reportableDiseases,
      isLoadingReportableDiseases: isLoadingReportableDiseases ?? this.isLoadingReportableDiseases,
      reportableDiseasesError: reportableDiseasesError ?? this.reportableDiseasesError,
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
    super.physicalRequirements,
    super.isLoadingPhysicalRequirements,
    super.physicalRequirementsError,
    super.reportableDiseases,
    super.isLoadingReportableDiseases,
    super.reportableDiseasesError,
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

