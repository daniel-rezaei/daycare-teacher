class ShiftDateEntity {
  final String? id;
  final List<String>? daysOfWeek;
  final String? startTime;
  final String? endTime;
  final String? dateCreated;
  final String? dateUpdated;

  const ShiftDateEntity({
    this.id,
    this.daysOfWeek,
    this.startTime,
    this.endTime,
    this.dateCreated,
    this.dateUpdated,
  });
}

