import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/activity/domain/entity/learning_plan_entity.dart';
import 'package:teacher_app/features/activity/domain/usecase/activity_usecase.dart';

part 'activity_event.dart';
part 'activity_state.dart';

@injectable
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityUsecase activityUsecase;

  ActivityBloc(this.activityUsecase) : super(ActivityInitial()) {
    on<LoadLearningPlansEvent>(_onLoadLearningPlans);
    on<LoadLearningPlanByIdEvent>(_onLoadLearningPlanById);
  }

  FutureOr<void> _onLoadLearningPlans(
    LoadLearningPlansEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(LoadLearningPlansLoading());

    final dataState = await activityUsecase.getLearningPlans(event.classId);

    if (dataState is DataSuccess) {
      emit(LoadLearningPlansSuccess(dataState.data ?? []));
    } else if (dataState is DataFailed) {
      emit(LoadLearningPlansFailure(dataState.error ?? 'Unknown error'));
    }
  }

  FutureOr<void> _onLoadLearningPlanById(
    LoadLearningPlanByIdEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(LoadLearningPlanByIdLoading());

    final dataState = await activityUsecase.getLearningPlanById(event.id);

    if (dataState is DataSuccess) {
      emit(LoadLearningPlanByIdSuccess(dataState.data));
    } else if (dataState is DataFailed) {
      emit(LoadLearningPlanByIdFailure(dataState.error ?? 'Unknown error'));
    }
  }
}
