import 'package:equatable/equatable.dart';

class ClassTransferRequestEntity extends Equatable {
  final String? id;
  final String? studentId;
  final String? fromClassId;
  final String? toClassId;
  final String? status;
  final String? dateCreated;
  final String? dateUpdated;

  const ClassTransferRequestEntity({
    this.id,
    this.studentId,
    this.fromClassId,
    this.toClassId,
    this.status,
    this.dateCreated,
    this.dateUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        fromClassId,
        toClassId,
        status,
        dateCreated,
        dateUpdated,
      ];
}
