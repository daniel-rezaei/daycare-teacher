class NotificationEntity {
  final String? id;
  final bool? isRead;
  final String? description;
  final String? type;
  final String? senderRole;
  final String? title;
  final String? sourceTable;
  final String? sourceId;
  final String? updatedAt;
  final String? readAt;
  final String? createdAt;
  final String? childId;
  final String? senderContactId;
  final String? recipientContactId;

  const NotificationEntity({
    this.id,
    this.isRead,
    this.description,
    this.type,
    this.senderRole,
    this.title,
    this.sourceTable,
    this.sourceId,
    this.updatedAt,
    this.readAt,
    this.createdAt,
    this.childId,
    this.senderContactId,
    this.recipientContactId,
  });
}
