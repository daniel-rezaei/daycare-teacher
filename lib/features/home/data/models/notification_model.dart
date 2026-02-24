import 'package:teacher_app/features/home/domain/entity/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    super.id,
    super.isRead,
    super.description,
    super.type,
    super.senderRole,
    super.title,
    super.sourceTable,
    super.sourceId,
    super.updatedAt,
    super.readAt,
    super.createdAt,
    super.childId,
    super.senderContactId,
    super.recipientContactId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String?,
      isRead: json['is_read'] as bool?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      senderRole: json['sender_role'] as String?,
      title: json['title'] as String?,
      sourceTable: json['source_table'] as String?,
      sourceId: json['source_id'] as String?,
      updatedAt: json['updated_at'] as String?,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String?,
      childId: json['child_id'] as String?,
      senderContactId: json['sender_contact_id'] as String?,
      recipientContactId: json['recipient_contact_id'] as String?,
    );
  }
}
