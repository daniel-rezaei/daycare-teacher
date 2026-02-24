part of 'child_profile_bloc.dart';

sealed class ChildProfileEvent extends Equatable {
  const ChildProfileEvent();

  @override
  List<Object> get props => [];
}

class PreloadChildMedicalDataEvent extends ChildProfileEvent {
  final String childId;

  const PreloadChildMedicalDataEvent({required this.childId});

  @override
  List<Object> get props => [childId];
}

class ClearChildProfileDataEvent extends ChildProfileEvent {
  const ClearChildProfileDataEvent();
}
