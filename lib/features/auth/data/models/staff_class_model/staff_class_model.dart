import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';

class StaffClassModel extends StaffClassEntity {
  const StaffClassModel({
    required super.id,
    required super.role,
    required super.staffId,
    required super.firstName,
    required super.lastName,
    required super.email,
  });

  factory StaffClassModel.fromJson(Map<String, dynamic> json) {
    final staff = json['staff_id'] as Map<String, dynamic>;
    final contact = staff['contact_id'] as Map<String, dynamic>;

    return StaffClassModel(
      id: json['id'] as String,
      role: json['Role'] as String,
      staffId: staff['id'] as String,
      firstName: contact['first_name'] as String,
      lastName: contact['last_name'] as String,
      email: contact['email'] as String,
    );
  }
}
