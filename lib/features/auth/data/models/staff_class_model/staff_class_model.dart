import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';

class StaffClassModel extends StaffClassEntity {
  const StaffClassModel({
    super.id,
    super.role,
    super.staffId,
    super.firstName,
    super.lastName,
    super.email,
    super.photoId,
  });

  factory StaffClassModel.fromJson(Map<String, dynamic> json) {
    final staff = json['staff_id'] as Map<String, dynamic>;
    final contact = staff['contact_id'] as Map<String, dynamic>;
    final photo = contact['photo'] as Map<String, dynamic>?;

    return StaffClassModel(
      id: json['id'] as String?,
      role: json['Role'] as String?,
      staffId: staff['id'] as String?,
      firstName: contact['first_name'] as String?,
      lastName: contact['last_name'] as String?,
      email: contact['email'] as String?,
      photoId: photo?['id'] as String?,
    );
  }
}
