import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/domain/usecase/child_usecase.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

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
  }

  FutureOr<void> _getAllChildrenEvent(
    GetAllChildrenEvent event,
    Emitter<ChildState> emit,
  ) async {
    // حفظ state قبلی قبل از emit loading
    final previousState = state;
    emit(GetAllChildrenLoading(
      children: previousState.children,
      contacts: previousState.contacts,
      dietaryRestrictions: previousState.dietaryRestrictions,
      medications: previousState.medications,
      isLoadingContacts: previousState.isLoadingContacts,
      isLoadingDietaryRestrictions: previousState.isLoadingDietaryRestrictions,
      isLoadingMedications: previousState.isLoadingMedications,
    ));

    try {
      DataState dataState = await childUsecase.getAllChildren();

      // استفاده از state فعلی (که ممکن است در این فاصله تغییر کرده باشد)
      final currentState = state;

      if (dataState is DataSuccess) {
        debugPrint('[CHILD_BLOC_DEBUG] GetAllChildrenSuccess: ${dataState.data.length} children');
        emit(GetAllChildrenSuccess(
          dataState.data,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[CHILD_BLOC_DEBUG] GetAllChildrenFailure: ${dataState.error}');
        emit(GetAllChildrenFailure(
          dataState.error!,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingContacts: currentState.isLoadingContacts,
          isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ));
      }
    } catch (e) {
      debugPrint('[CHILD_BLOC_DEBUG] Exception getting children: $e');
      final currentState = state;
      emit(GetAllChildrenFailure(
        'خطا در دریافت اطلاعات بچه‌ها',
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
        medications: currentState.medications ?? previousState.medications,
        isLoadingContacts: currentState.isLoadingContacts,
        isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
        isLoadingMedications: currentState.isLoadingMedications,
      ));
    }
  }

  FutureOr<void> _getAllContactsEvent(
    GetAllContactsEvent event,
    Emitter<ChildState> emit,
  ) async {
    // حفظ state قبلی قبل از emit loading
    final previousState = state;
    emit(GetAllContactsLoading(
      children: previousState.children,
      contacts: previousState.contacts,
      dietaryRestrictions: previousState.dietaryRestrictions,
      medications: previousState.medications,
      isLoadingChildren: previousState.isLoadingChildren,
      isLoadingDietaryRestrictions: previousState.isLoadingDietaryRestrictions,
      isLoadingMedications: previousState.isLoadingMedications,
    ));

    try {
      DataState dataState = await childUsecase.getAllContacts();

      // استفاده از state فعلی (که ممکن است در این فاصله تغییر کرده باشد)
      final currentState = state;
      
      if (dataState is DataSuccess) {
        debugPrint('[CHILD_BLOC_DEBUG] GetAllContactsSuccess: ${dataState.data.length} contacts');
        emit(GetAllContactsSuccess(
          dataState.data,
          children: currentState.children ?? previousState.children,
          dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ));
      } else if (dataState is DataFailed) {
        debugPrint('[CHILD_BLOC_DEBUG] GetAllContactsFailure: ${dataState.error}');
        emit(GetAllContactsFailure(
          dataState.error!,
          children: currentState.children ?? previousState.children,
          contacts: currentState.contacts ?? previousState.contacts,
          dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
          medications: currentState.medications ?? previousState.medications,
          isLoadingChildren: currentState.isLoadingChildren,
          isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
          isLoadingMedications: currentState.isLoadingMedications,
        ));
      }
    } catch (e) {
      debugPrint('[CHILD_BLOC_DEBUG] Exception getting contacts: $e');
      final currentState = state;
      emit(GetAllContactsFailure(
        'خطا در دریافت اطلاعات Contacts',
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
        medications: currentState.medications ?? previousState.medications,
        isLoadingChildren: currentState.isLoadingChildren,
        isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
        isLoadingMedications: currentState.isLoadingMedications,
      ));
    }
  }

  FutureOr<void> _getAllDietaryRestrictionsEvent(
    GetAllDietaryRestrictionsEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(GetAllDietaryRestrictionsLoading(
      children: previousState.children,
      contacts: previousState.contacts,
      dietaryRestrictions: previousState.dietaryRestrictions,
      medications: previousState.medications,
      isLoadingChildren: previousState.isLoadingChildren,
      isLoadingContacts: previousState.isLoadingContacts,
      isLoadingMedications: previousState.isLoadingMedications,
    ));

    DataState dataState = await childUsecase.getAllDietaryRestrictions();

    final currentState = state;

    if (dataState is DataSuccess) {
      emit(GetAllDietaryRestrictionsSuccess(
        dataState.data,
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        medications: currentState.medications ?? previousState.medications,
        isLoadingChildren: currentState.isLoadingChildren,
        isLoadingContacts: currentState.isLoadingContacts,
        isLoadingMedications: currentState.isLoadingMedications,
      ));
    }

    if (dataState is DataFailed) {
      emit(GetAllDietaryRestrictionsFailure(
        dataState.error!,
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
        medications: currentState.medications ?? previousState.medications,
        isLoadingChildren: currentState.isLoadingChildren,
        isLoadingContacts: currentState.isLoadingContacts,
        isLoadingMedications: currentState.isLoadingMedications,
      ));
    }
  }

  FutureOr<void> _getAllMedicationsEvent(
    GetAllMedicationsEvent event,
    Emitter<ChildState> emit,
  ) async {
    final previousState = state;
    emit(GetAllMedicationsLoading(
      children: previousState.children,
      contacts: previousState.contacts,
      dietaryRestrictions: previousState.dietaryRestrictions,
      medications: previousState.medications,
      isLoadingChildren: previousState.isLoadingChildren,
      isLoadingContacts: previousState.isLoadingContacts,
      isLoadingDietaryRestrictions: previousState.isLoadingDietaryRestrictions,
    ));

    DataState dataState = await childUsecase.getAllMedications();

    final currentState = state;

    if (dataState is DataSuccess) {
      emit(GetAllMedicationsSuccess(
        dataState.data,
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
        isLoadingChildren: currentState.isLoadingChildren,
        isLoadingContacts: currentState.isLoadingContacts,
        isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
      ));
    }

    if (dataState is DataFailed) {
      emit(GetAllMedicationsFailure(
        dataState.error!,
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        dietaryRestrictions: currentState.dietaryRestrictions ?? previousState.dietaryRestrictions,
        medications: currentState.medications ?? previousState.medications,
        isLoadingChildren: currentState.isLoadingChildren,
        isLoadingContacts: currentState.isLoadingContacts,
        isLoadingDietaryRestrictions: currentState.isLoadingDietaryRestrictions,
      ));
    }
  }
}

