class ChildGuardianEntity {
  final String? id;
  final String? childId;
  final String? contactId;
  final String? relation;
  final bool? pickupAuthorized;
  final String? dateCreated;
  final String? dateUpdated;

  const ChildGuardianEntity({
    this.id,
    this.childId,
    this.contactId,
    this.relation,
    this.pickupAuthorized,
    this.dateCreated,
    this.dateUpdated,
  });
}

