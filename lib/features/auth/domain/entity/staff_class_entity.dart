import 'package:equatable/equatable.dart';

class StaffClassEntity extends Equatable {
  final String? id;
  final String? role;
  final String? note;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;
  final String? userCreated;
  final String? userUpdated;

  /// 🔹 Directus relations (UUIDs)
  final List<String>? staffIds;
  final List<String>? classIds;

  const StaffClassEntity({
    this.id,
    this.role,
    this.note,
    this.dateCreated,
    this.dateUpdated,
    this.userCreated,
    this.userUpdated,
    this.staffIds,
    this.classIds,
  });

  @override
  List<Object?> get props => [
    id,
    role,
    note,
    dateCreated,
    dateUpdated,
    userCreated,
    userUpdated,
    staffIds,
    classIds,
  ];
}
