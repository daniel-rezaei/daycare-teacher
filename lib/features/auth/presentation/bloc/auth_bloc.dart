import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/domain/usecase/auth_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;
  AuthBloc(this.authUsecase) : super(AuthInitial()) {
    on<GetClassRoomsEvent>(_getClassRoomsEvent);
    on<GetStaffClassEvent>(_getStaffClassEvent);
  }

  FutureOr<void> _getClassRoomsEvent(
    GetClassRoomsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(GetClassRoomsLoading());

    DataState dataState = await authUsecase.classRoom();

    if (dataState is DataSuccess) {
      emit(GetClassRoomsSuccess(dataState.data));
    }

    if (dataState is DataFailed) {
      emit(GetClassRoomsFailure(dataState.error!));
    }
  }

  FutureOr<void> _getStaffClassEvent(
    GetStaffClassEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(GetStaffClassLoading());

    DataState dataState = await authUsecase.staffClass();

    if (dataState is DataSuccess) {
      emit(GetStaffClassSuccess(dataState.data));
    } else if (dataState is DataFailed) {
      emit(GetStaffClassFailure(dataState.error!));
    }
  }
}
