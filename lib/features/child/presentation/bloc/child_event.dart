part of 'child_bloc.dart';

sealed class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object> get props => [];
}

/// Event for fetching all children
class GetAllChildrenEvent extends ChildEvent {
  const GetAllChildrenEvent();
}

/// Event for fetching all contacts
class GetAllContactsEvent extends ChildEvent {
  const GetAllContactsEvent();
}

