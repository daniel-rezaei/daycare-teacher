import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/home/domain/usecase/profile_usecase.dart';

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
        emit(GetContactFailure(dataState.error!));
      }
    } catch (e) {
      emit(GetContactFailure('Error retrieving profile information'));
    }
  }
}
