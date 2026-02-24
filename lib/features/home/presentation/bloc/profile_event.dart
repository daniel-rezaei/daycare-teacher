part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetContactEvent extends ProfileEvent {
  final String id;
  const GetContactEvent({required this.id});

  @override
  List<Object> get props => [id];
}
