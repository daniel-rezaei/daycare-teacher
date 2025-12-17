part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching contact information
class GetContactEvent extends ProfileEvent {
  final String id;
  const GetContactEvent({required this.id});

  @override
  List<Object> get props => [id];
}

