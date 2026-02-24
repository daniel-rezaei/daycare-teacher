part of 'child_status_module_bloc.dart';

sealed class ChildStatusModuleState extends Equatable {
  const ChildStatusModuleState();

  @override
  List<Object?> get props => [];
}

final class ChildStatusModuleInitial extends ChildStatusModuleState {}

final class LoadChildrenStatusLoading extends ChildStatusModuleState {}

final class LoadChildrenStatusSuccess extends ChildStatusModuleState {
  final ChildStatusAggregateEntity aggregate;

  const LoadChildrenStatusSuccess(this.aggregate);

  @override
  List<Object?> get props => [aggregate];
}

final class LoadChildrenStatusFailure extends ChildStatusModuleState {
  final String message;

  const LoadChildrenStatusFailure(this.message);

  @override
  List<Object?> get props => [message];
}
