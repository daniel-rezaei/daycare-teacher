part of 'child_bloc.dart';

sealed class ChildState extends Equatable {
  final List<ChildEntity>? children;
  final List<ContactEntity>? contacts;
  final bool isLoadingChildren;
  final bool isLoadingContacts;
  final String? childrenError;
  final String? contactsError;

  const ChildState({
    this.children,
    this.contacts,
    this.isLoadingChildren = false,
    this.isLoadingContacts = false,
    this.childrenError,
    this.contactsError,
  });

  @override
  List<Object?> get props => [
        children,
        contacts,
        isLoadingChildren,
        isLoadingContacts,
        childrenError,
        contactsError,
      ];
}

final class ChildInitial extends ChildState {
  const ChildInitial();
}

/// Loading state for getting all children
final class GetAllChildrenLoading extends ChildState {
  const GetAllChildrenLoading({
    super.children,
    super.contacts,
    super.isLoadingContacts,
  }) : super(isLoadingChildren: true);
}

/// Success state for getting all children
final class GetAllChildrenSuccess extends ChildState {
  const GetAllChildrenSuccess(
    List<ChildEntity> children, {
    super.contacts,
    super.isLoadingContacts,
  }) : super(
          children: children,
          isLoadingChildren: false,
        );
}

/// Failure state for getting all children
final class GetAllChildrenFailure extends ChildState {
  const GetAllChildrenFailure(
    String message, {
    super.children,
    super.contacts,
    super.isLoadingContacts,
  }) : super(
          childrenError: message,
          isLoadingChildren: false,
        );
}

/// Loading state for getting all contacts
final class GetAllContactsLoading extends ChildState {
  const GetAllContactsLoading({
    super.children,
    super.contacts,
    super.isLoadingChildren,
  }) : super(isLoadingContacts: true);
}

/// Success state for getting all contacts
final class GetAllContactsSuccess extends ChildState {
  const GetAllContactsSuccess(
    List<ContactEntity> contacts, {
    super.children,
    super.isLoadingChildren,
  }) : super(
          contacts: contacts,
          isLoadingContacts: false,
        );
}

/// Failure state for getting all contacts
final class GetAllContactsFailure extends ChildState {
  const GetAllContactsFailure(
    String message, {
    super.children,
    super.contacts,
    super.isLoadingChildren,
  }) : super(
          contactsError: message,
          isLoadingContacts: false,
        );
}

