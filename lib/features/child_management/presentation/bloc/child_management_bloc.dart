import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_status_aggregate_entity.dart';
import 'package:teacher_app/features/child_management/domain/usecase/child_status_usecase.dart';
import 'package:teacher_app/features/child_management/utils/child_status_logger.dart';

part 'child_management_event.dart';
part 'child_management_state.dart';

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
    final isRefresh = state is LoadChildrenStatusSuccess;
    childStatusLog('Bloc: LoadChildrenStatus classId=${event.classId} isRefresh=$isRefresh');
    // اگر قبلاً دادهٔ موفق داریم، برای رفرش دوباره صفحه را وارد حالت لودینگ نکن
    if (state is! LoadChildrenStatusSuccess) {
      emit(LoadChildrenStatusLoading());
    }

    final dataState =
        await childStatusUsecase.getChildrenStatus(event.classId);

    if (dataState is DataSuccess) {
      final agg = dataState.data!;
      childStatusLog('Bloc: LoadChildrenStatus SUCCESS children=${agg.children.length} attendance=${agg.attendanceList.length}');
      emit(LoadChildrenStatusSuccess(agg));
    } else if (dataState is DataFailed) {
      childStatusLog('Bloc: LoadChildrenStatus FAILED ${dataState.error}', isError: true);
      emit(LoadChildrenStatusFailure(dataState.error ?? 'Unknown error'));
    }
  }
}
