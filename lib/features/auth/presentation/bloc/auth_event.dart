part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching class rooms
class GetClassRoomsEvent extends AuthEvent {
  const GetClassRoomsEvent();
}

/// Event for fetching staff class
class GetStaffClassEvent extends AuthEvent {
  const GetStaffClassEvent();
}
