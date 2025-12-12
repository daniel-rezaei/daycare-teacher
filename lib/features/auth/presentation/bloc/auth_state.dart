part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

/// Loading state for getting class rooms
final class GetClassRoomsLoading extends AuthState {}

/// Success state for getting class rooms
final class GetClassRoomsSuccess extends AuthState {
  final List<ClassRoomEntity> classRooms;

  const GetClassRoomsSuccess(this.classRooms);
}

/// Failure state for getting class rooms
final class GetClassRoomsFailure extends AuthState {
  final String message;

  const GetClassRoomsFailure(this.message);
}

/// Loading state for getting staff class
final class GetStaffClassLoading extends AuthState {}

/// Success state for getting staff class
final class GetStaffClassSuccess extends AuthState {
  final List<StaffClassEntity> staffClasses;

  const GetStaffClassSuccess(this.staffClasses);
}

/// Failure state for getting staff class
final class GetStaffClassFailure extends AuthState {
  final String message;

  const GetStaffClassFailure(this.message);
}
