import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_emergency_contact/domain/entity/child_emergency_contact_entity.dart';
import 'package:teacher_app/features/child_emergency_contact/domain/usecase/child_emergency_contact_usecase.dart';

part 'child_emergency_contact_event.dart';
part 'child_emergency_contact_state.dart';

@injectable
class ChildEmergencyContactBloc
    extends Bloc<ChildEmergencyContactEvent, ChildEmergencyContactState> {
  final ChildEmergencyContactUsecase childEmergencyContactUsecase;
  ChildEmergencyContactBloc(this.childEmergencyContactUsecase)
      : super(const ChildEmergencyContactInitial()) {
    on<GetAllChildEmergencyContactsEvent>(
        _getAllChildEmergencyContactsEvent);
  }

  FutureOr<void> _getAllChildEmergencyContactsEvent(
    GetAllChildEmergencyContactsEvent event,
    Emitter<ChildEmergencyContactState> emit,
  ) async {
    emit(const GetAllChildEmergencyContactsLoading());

    try {
      DataState dataState =
          await childEmergencyContactUsecase.getAllChildEmergencyContacts();

      if (dataState is DataSuccess) {
        debugPrint(
            '[CHILD_EMERGENCY_CONTACT_DEBUG] GetAllChildEmergencyContactsSuccess: ${dataState.data?.length} items');
        emit(GetAllChildEmergencyContactsSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint(
            '[CHILD_EMERGENCY_CONTACT_DEBUG] GetAllChildEmergencyContactsFailure: ${dataState.error}');
        emit(GetAllChildEmergencyContactsFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint(
          '[CHILD_EMERGENCY_CONTACT_DEBUG] Exception getting all child emergency contacts: $e');
      emit(const GetAllChildEmergencyContactsFailure(
          'Error retrieving information'));
    }
  }
}

