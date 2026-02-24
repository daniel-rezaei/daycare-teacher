part of 'child_status_module_bloc.dart';

sealed class ChildStatusModuleEvent extends Equatable {
  const ChildStatusModuleEvent();

  @override
  List<Object?> get props => [];
}

class LoadChildrenStatusEvent extends ChildStatusModuleEvent {
  final String classId;

  const LoadChildrenStatusEvent({required this.classId});

  @override
  List<Object?> get props => [classId];
}
