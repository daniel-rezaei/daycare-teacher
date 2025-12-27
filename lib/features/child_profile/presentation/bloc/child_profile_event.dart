part of 'child_profile_bloc.dart';

sealed class ChildProfileEvent extends Equatable {
  const ChildProfileEvent();

  @override
  List<Object> get props => [];
}

/// Event to preload all medical data for a specific childId
/// This should be dispatched BEFORE navigating to Child Profile
class PreloadChildMedicalDataEvent extends ChildProfileEvent {
  final String childId;

  const PreloadChildMedicalDataEvent({required this.childId});

  @override
  List<Object> get props => [childId];
}

/// Event to clear child profile data
class ClearChildProfileDataEvent extends ChildProfileEvent {
  const ClearChildProfileDataEvent();
}

