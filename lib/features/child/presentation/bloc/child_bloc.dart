import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/domain/usecase/child_usecase.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/immunization/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/reportable_disease/domain/entity/reportable_disease_entity.dart';

part 'child_event.dart';
part 'child_state.dart';

@injectable
class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final ChildUsecase childUsecase;
  ChildBloc(this.childUsecase) : super(ChildInitial()) {
    on<GetAllChildrenEvent>(_getAllChildrenEvent);
    on<GetAllContactsEvent>(_getAllContactsEvent);
    on<GetAllDietaryRestrictionsEvent>(_getAllDietaryRestrictionsEvent);
    on<GetAllMedicationsEvent>(_getAllMedicationsEvent);
    on<GetAllPhysicalRequirementsEvent>(_getAllPhysicalRequirementsEvent);
    on<GetAllReportableDiseasesEvent>(_getAllReportableDiseasesEvent);
    on<GetAllImmunizationsEvent>(_getAllImmunizationsEvent);
    on<GetChildByIdEvent>(_getChildByIdEvent);
    on<GetChildByContactIdEvent>(_getChildByContactIdEvent);
  }

  FutureOr<void> _getAllChildrenEvent(
    GetAllChildrenEvent event,
    Emitter<ChildState> emit,
  ) async {
    // حفظ state قبلی قبل از emit loading
    final previousState = state;
    emit(
      GetAllChildrenLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
        isLoadingMedications: previousState.isLoadingMedications,
      ),
    );

    try {
      DataState dataState = await childUsecase.getAllChildren();

      // استفاده از state فعلی (که ممکن است در این فاصله تغییر کرده باشد)
      final currentState = state;

      if (dataState is DataSuccess) {
        emit(
          GetAllChildrenSuccess(
            dataState.data,
            contacts: currentState.contacts ?? previousState.contacts,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            isLoadingContacts: currentState.isLoadingContacts,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          GetAllChildrenFailure(
            dataState.error!,
            children: currentState.children ?? previousState.children,
            contacts: currentState.contacts ?? previousState.contacts,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            isLoadingContacts: currentState.isLoadingContacts,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      }
    } catch (e) {
      final currentState = state;
      emit(
        GetAllChildrenFailure(
          'Error retrieving children information',
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ),
      );
    }
  }

  FutureOr<void> _getAllContactsEvent(
    GetAllContactsEvent event,
    Emitter<ChildState> emit,
  ) async {
    // حفظ state قبلی قبل از emit loading
    final previousState = state;
    emit(
      GetAllContactsLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
        isLoadingMedications: previousState.isLoadingMedications,
      ),
    );

    try {
      DataState dataState = await childUsecase.getAllContacts();

      // استفاده از state فعلی (که ممکن است در این فاصله تغییر کرده باشد)
      final currentState = state;

      if (dataState is DataSuccess) {
        emit(
          GetAllContactsSuccess(
            dataState.data,
            children: currentState.children ?? previousState.children,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            isLoadingChildren: currentState.isLoadingChildren,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          GetAllContactsFailure(
            dataState.error!,
            children: currentState.children ?? previousState.children,
            contacts: currentState.contacts ?? previousState.contacts,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            isLoadingChildren: currentState.isLoadingChildren,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      }
    } catch (e) {
      final currentState = state;
      emit(
        GetAllContactsFailure(
          'Error retrieving Contacts information',
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ),
      );
    }
  }

  FutureOr<void> _getAllDietaryRestrictionsEvent(
    GetAllDietaryRestrictionsEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(
      GetAllDietaryRestrictionsLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingMedications: previousState.isLoadingMedications,
      ),
    );

    DataState dataState = await childUsecase.getAllDietaryRestrictions();

    final currentState = state;

    if (dataState is DataSuccess) {
      emit(
        GetAllDietaryRestrictionsSuccess(
          dataState.data,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          medications: currentState.medications ?? previousState.medications,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingMedications: currentState.isLoadingMedications,
        ),
      );
    }

    if (dataState is DataFailed) {
      emit(
        GetAllDietaryRestrictionsFailure(
          dataState.error!,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingMedications: currentState.isLoadingMedications,
        ),
      );
    }
  }

  FutureOr<void> _getAllMedicationsEvent(
    GetAllMedicationsEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(
      GetAllMedicationsLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
      ),
    );

    DataState dataState = await childUsecase.getAllMedications();

    final currentState = state;

    if (dataState is DataSuccess) {
      emit(
        GetAllMedicationsSuccess(
          dataState.data,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
        ),
      );
    }

    if (dataState is DataFailed) {
      emit(
        GetAllMedicationsFailure(
          dataState.error!,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
        ),
      );
    }
  }

  FutureOr<void> _getAllPhysicalRequirementsEvent(
    GetAllPhysicalRequirementsEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(
      GetAllPhysicalRequirementsLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        physicalRequirements: previousState.physicalRequirements,
        reportableDiseases: previousState.reportableDiseases,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
        isLoadingMedications: previousState.isLoadingMedications,
        isLoadingReportableDiseases: previousState.isLoadingReportableDiseases,
      ),
    );

    DataState dataState = await childUsecase.getAllPhysicalRequirements();

    final currentState = state;

    if (dataState is DataSuccess) {
      emit(
        GetAllPhysicalRequirementsSuccess(
          dataState.data,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          reportableDiseases:
              currentState.reportableDiseases ??
              previousState.reportableDiseases,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
          isLoadingReportableDiseases: currentState.isLoadingReportableDiseases,
        ),
      );
    }

    if (dataState is DataFailed) {
      emit(
        GetAllPhysicalRequirementsFailure(
          dataState.error!,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          physicalRequirements:
              currentState.physicalRequirements ??
              previousState.physicalRequirements,
          reportableDiseases:
              currentState.reportableDiseases ??
              previousState.reportableDiseases,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
          isLoadingReportableDiseases: currentState.isLoadingReportableDiseases,
        ),
      );
    }
  }

  FutureOr<void> _getAllReportableDiseasesEvent(
    GetAllReportableDiseasesEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(
      GetAllReportableDiseasesLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        physicalRequirements: previousState.physicalRequirements,
        reportableDiseases: previousState.reportableDiseases,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
        isLoadingMedications: previousState.isLoadingMedications,
        isLoadingPhysicalRequirements:
            previousState.isLoadingPhysicalRequirements,
      ),
    );

    DataState dataState = await childUsecase.getAllReportableDiseases();

    final currentState = state;

    if (dataState is DataSuccess) {
      emit(
        GetAllReportableDiseasesSuccess(
          dataState.data,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          physicalRequirements:
              currentState.physicalRequirements ??
              previousState.physicalRequirements,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
          isLoadingPhysicalRequirements:
              currentState.isLoadingPhysicalRequirements,
        ),
      );
    }

    if (dataState is DataFailed) {
      emit(
        GetAllReportableDiseasesFailure(
          dataState.error!,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          physicalRequirements:
              currentState.physicalRequirements ??
              previousState.physicalRequirements,
          reportableDiseases:
              currentState.reportableDiseases ??
              previousState.reportableDiseases,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
          isLoadingPhysicalRequirements:
              currentState.isLoadingPhysicalRequirements,
        ),
      );
    }
  }

  FutureOr<void> _getAllImmunizationsEvent(
    GetAllImmunizationsEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(
      GetAllImmunizationsLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        physicalRequirements: previousState.physicalRequirements,
        reportableDiseases: previousState.reportableDiseases,
        immunizations: previousState.immunizations,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
        isLoadingMedications: previousState.isLoadingMedications,
        isLoadingPhysicalRequirements:
            previousState.isLoadingPhysicalRequirements,
        isLoadingReportableDiseases: previousState.isLoadingReportableDiseases,
      ),
    );

    DataState dataState = await childUsecase.getAllImmunizations();

    final currentState = state;

    if (dataState is DataSuccess) {
      emit(
        GetAllImmunizationsSuccess(
          dataState.data,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          physicalRequirements:
              currentState.physicalRequirements ??
              previousState.physicalRequirements,
          reportableDiseases:
              currentState.reportableDiseases ??
              previousState.reportableDiseases,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
          isLoadingPhysicalRequirements:
              currentState.isLoadingPhysicalRequirements,
          isLoadingReportableDiseases: currentState.isLoadingReportableDiseases,
        ),
      );
    }

    if (dataState is DataFailed) {
      emit(
        GetAllImmunizationsFailure(
          dataState.error!,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          physicalRequirements:
              currentState.physicalRequirements ??
              previousState.physicalRequirements,
          reportableDiseases:
              currentState.reportableDiseases ??
              previousState.reportableDiseases,
          immunizations:
              currentState.immunizations ?? previousState.immunizations,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
          isLoadingPhysicalRequirements:
              currentState.isLoadingPhysicalRequirements,
          isLoadingReportableDiseases: currentState.isLoadingReportableDiseases,
        ),
      );
    }
  }

  FutureOr<void> _getChildByIdEvent(
    GetChildByIdEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(
      GetChildByIdLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        child: previousState.child,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
        isLoadingMedications: previousState.isLoadingMedications,
      ),
    );

    try {
      DataState dataState = await childUsecase.getChildById(
        childId: event.childId,
      );

      final currentState = state;

      if (dataState is DataSuccess) {
        emit(
          GetChildByIdSuccess(
            dataState.data,
            children: currentState.children ?? previousState.children,
            contacts: currentState.contacts ?? previousState.contacts,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            isLoadingChildren: currentState.isLoadingChildren,
            isLoadingContacts: currentState.isLoadingContacts,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          GetChildByIdFailure(
            dataState.error!,
            children: currentState.children ?? previousState.children,
            contacts: currentState.contacts ?? previousState.contacts,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            child: currentState.child ?? previousState.child,
            isLoadingChildren: currentState.isLoadingChildren,
            isLoadingContacts: currentState.isLoadingContacts,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      }
    } catch (e) {
      final currentState = state;
      emit(
        GetChildByIdFailure(
          'Error retrieving child information',
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          child: currentState.child ?? previousState.child,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ),
      );
    }
  }

  FutureOr<void> _getChildByContactIdEvent(
    GetChildByContactIdEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(
      GetChildByContactIdLoading(
        children: previousState.children,
        contacts: previousState.contacts,
        dietaryRestrictions: previousState.dietaryRestrictions,
        medications: previousState.medications,
        child: previousState.child,
        isLoadingChildren: previousState.isLoadingChildren,
        isLoadingContacts: previousState.isLoadingContacts,
        isLoadingDietaryRestrictions:
            previousState.isLoadingDietaryRestrictions,
        isLoadingMedications: previousState.isLoadingMedications,
      ),
    );

    try {
      DataState dataState = await childUsecase.getChildByContactId(
        contactId: event.contactId,
      );

      final currentState = state;

      if (dataState is DataSuccess) {
        emit(
          GetChildByContactIdSuccess(
            dataState.data,
            children: currentState.children ?? previousState.children,
            contacts: currentState.contacts ?? previousState.contacts,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            isLoadingChildren: currentState.isLoadingChildren,
            isLoadingContacts: currentState.isLoadingContacts,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      } else if (dataState is DataFailed) {
        emit(
          GetChildByContactIdFailure(
            dataState.error!,
            children: currentState.children ?? previousState.children,
            contacts: currentState.contacts ?? previousState.contacts,
            dietaryRestrictions:
                currentState.dietaryRestrictions ??
                previousState.dietaryRestrictions,
            medications: currentState.medications ?? previousState.medications,
            child: currentState.child ?? previousState.child,
            isLoadingChildren: currentState.isLoadingChildren,
            isLoadingContacts: currentState.isLoadingContacts,
            isLoadingDietaryRestrictions:
                currentState.isLoadingDietaryRestrictions,
            isLoadingMedications: currentState.isLoadingMedications,
          ),
        );
      }
    } catch (e) {
      final currentState = state;
      emit(
        GetChildByContactIdFailure(
          'Error retrieving child information',
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions:
              currentState.dietaryRestrictions ??
              previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          child: currentState.child ?? previousState.child,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions:
              currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ),
      );
    }
  }
}
