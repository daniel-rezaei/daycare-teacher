part of 'child_guardian_bloc.dart';

sealed class ChildGuardianEvent extends Equatable {
  const ChildGuardianEvent();

  @override
  List<Object> get props => [];
}

class GetChildGuardianByChildIdEvent extends ChildGuardianEvent {
  final String childId;

  const GetChildGuardianByChildIdEvent({required this.childId});

  @override
  List<Object> get props => [childId];
}

