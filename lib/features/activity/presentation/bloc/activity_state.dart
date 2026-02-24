part of 'activity_bloc.dart';

sealed class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

final class ActivityInitial extends ActivityState {}

final class LoadLearningPlansLoading extends ActivityState {}

final class LoadLearningPlansSuccess extends ActivityState {
  final List<LearningPlanEntity> plans;

  const LoadLearningPlansSuccess(this.plans);

  @override
  List<Object?> get props => [plans];
}

final class LoadLearningPlansFailure extends ActivityState {
  final String message;

  const LoadLearningPlansFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class LoadLearningPlanByIdLoading extends ActivityState {}

final class LoadLearningPlanByIdSuccess extends ActivityState {
  final LearningPlanEntity? plan;

  const LoadLearningPlanByIdSuccess(this.plan);

  @override
  List<Object?> get props => [plan];
}

final class LoadLearningPlanByIdFailure extends ActivityState {
  final String message;

  const LoadLearningPlanByIdFailure(this.message);

  @override
  List<Object?> get props => [message];
}
