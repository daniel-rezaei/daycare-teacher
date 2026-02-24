import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_status_module/domain/entity/child_status_aggregate_entity.dart';
import 'package:teacher_app/features/child_status_module/domain/usecase/child_status_usecase.dart';

part 'child_status_module_event.dart';
part 'child_status_module_state.dart';

@injectable
class ChildStatusModuleBloc
    extends Bloc<ChildStatusModuleEvent, ChildStatusModuleState> {
  final ChildStatusUsecase childStatusUsecase;

  ChildStatusModuleBloc(this.childStatusUsecase)
      : super(ChildStatusModuleInitial()) {
    on<LoadChildrenStatusEvent>(_onLoadChildrenStatus);
  }

  FutureOr<void> _onLoadChildrenStatus(
    LoadChildrenStatusEvent event,
    Emitter<ChildStatusModuleState> emit,
  ) async {
    emit(LoadChildrenStatusLoading());

    final dataState =
        await childStatusUsecase.getChildrenStatus(event.classId);

    if (dataState is DataSuccess) {
      emit(LoadChildrenStatusSuccess(dataState.data!));
    } else if (dataState is DataFailed) {
      emit(LoadChildrenStatusFailure(dataState.error ?? 'Unknown error'));
    }
  }
}
