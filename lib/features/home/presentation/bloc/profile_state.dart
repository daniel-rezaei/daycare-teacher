part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class GetContactLoading extends ProfileState {}

final class GetContactSuccess extends ProfileState {
  final ContactEntity contact;

  const GetContactSuccess(this.contact);

  @override
  List<Object> get props => [contact];
}

final class GetContactFailure extends ProfileState {
  final String message;

  const GetContactFailure(this.message);

  @override
  List<Object> get props => [message];
}
