import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_guardian/domain/entity/child_guardian_entity.dart';
import 'package:teacher_app/features/child_guardian/domain/usecase/child_guardian_usecase.dart';

part 'child_guardian_event.dart';
part 'child_guardian_state.dart';

@injectable
class ChildGuardianBloc extends Bloc<ChildGuardianEvent, ChildGuardianState> {
  final ChildGuardianUsecase childGuardianUsecase;
  ChildGuardianBloc(this.childGuardianUsecase)
    : super(const ChildGuardianInitial()) {
    on<GetChildGuardianByChildIdEvent>(_getChildGuardianByChildIdEvent);
  }

  FutureOr<void> _getChildGuardianByChildIdEvent(
    GetChildGuardianByChildIdEvent event,
    Emitter<ChildGuardianState> emit,
  ) async {
    emit(const GetChildGuardianByChildIdLoading());

    try {
      DataState dataState = await childGuardianUsecase
          .getChildGuardianByChildId(childId: event.childId);

      if (dataState is DataSuccess) {
        emit(GetChildGuardianByChildIdSuccess(dataState.data));
      } else if (dataState is DataFailed) {
        emit(GetChildGuardianByChildIdFailure(dataState.error!));
      }
    } catch (e) {
      emit(
        const GetChildGuardianByChildIdFailure('Error retrieving information'),
      );
    }
  }
}
