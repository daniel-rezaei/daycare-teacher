class AttendanceChildEntity {
  final String? id;
  final String? checkInAt;
  final String? checkOutAt;
  final String? childId;
  final String? classId;
  final String? staffId;
  final String? checkInMethod;
  final String? checkOutMethod;
  final String? notes;

  const AttendanceChildEntity({
    this.id,
    this.checkInAt,
    this.checkOutAt,
    this.childId,
    this.classId,
    this.staffId,
    this.checkInMethod,
    this.checkOutMethod,
    this.notes,
  });
}
