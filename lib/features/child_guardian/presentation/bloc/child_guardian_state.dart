part of 'child_guardian_bloc.dart';

sealed class ChildGuardianState extends Equatable {
  const ChildGuardianState();

  @override
  List<Object?> get props => [];
}

final class ChildGuardianInitial extends ChildGuardianState {
  const ChildGuardianInitial();
}

final class GetChildGuardianByChildIdLoading extends ChildGuardianState {
  const GetChildGuardianByChildIdLoading();
}

final class GetChildGuardianByChildIdSuccess extends ChildGuardianState {
  final List<ChildGuardianEntity> guardianList;
  const GetChildGuardianByChildIdSuccess(this.guardianList);
  @override
  List<Object?> get props => [guardianList];
}

final class GetChildGuardianByChildIdFailure extends ChildGuardianState {
  final String message;
  const GetChildGuardianByChildIdFailure(this.message);
  @override
  List<Object?> get props => [message];
}

