import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/domain/usecase/child_usecase.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

part 'child_event.dart';
part 'child_state.dart';

@injectable
class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final ChildUsecase childUsecase;
  ChildBloc(this.childUsecase) : super(const ChildInitial()) {
    on<GetAllChildrenEvent>(_getAllChildrenEvent);
    on<GetAllContactsEvent>(_getAllContactsEvent);
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
      isLoadingContacts: previousState.isLoadingContacts,
    ));

    DataState dataState = await childUsecase.getAllChildren();

    // استفاده از state فعلی (که ممکن است در این فاصله تغییر کرده باشد)
    final currentState = state;

    if (dataState is DataSuccess) {
      emit(GetAllChildrenSuccess(
        dataState.data,
        contacts: currentState.contacts ?? previousState.contacts,
        isLoadingContacts: currentState.isLoadingContacts,
      ));
    }

    if (dataState is DataFailed) {
      emit(GetAllChildrenFailure(
        dataState.error!,
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        isLoadingContacts: currentState.isLoadingContacts,
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
      isLoadingChildren: previousState.isLoadingChildren,
    ));

    DataState dataState = await childUsecase.getAllContacts();

    // استفاده از state فعلی (که ممکن است در این فاصله تغییر کرده باشد)
    final currentState = state;
    
    if (dataState is DataSuccess) {
      emit(GetAllContactsSuccess(
        dataState.data,
        children: currentState.children ?? previousState.children,
        isLoadingChildren: currentState.isLoadingChildren,
      ));
    }

    if (dataState is DataFailed) {
      emit(GetAllContactsFailure(
        dataState.error!,
        children: currentState.children ?? previousState.children,
        contacts: currentState.contacts ?? previousState.contacts,
        isLoadingChildren: currentState.isLoadingChildren,
      ));
    }
  }
}

