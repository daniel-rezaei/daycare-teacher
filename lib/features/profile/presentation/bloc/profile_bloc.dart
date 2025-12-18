import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/profile/domain/usecase/profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileUsecase profileUsecase;
  ProfileBloc(this.profileUsecase) : super(ProfileInitial()) {
    on<GetContactEvent>(_getContactEvent);
  }

  FutureOr<void> _getContactEvent(
    GetContactEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(GetContactLoading());

    try {
      DataState dataState = await profileUsecase.getContact(id: event.id);

      if (dataState is DataSuccess) {
        emit(GetContactSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        debugPrint('[PROFILE_DEBUG] Error getting contact: ${dataState.error}');
        emit(GetContactFailure(dataState.error!));
      }
    } catch (e) {
      debugPrint('[PROFILE_DEBUG] Exception getting contact: $e');
      emit(GetContactFailure('خطا در دریافت اطلاعات پروفایل'));
    }
  }
}

