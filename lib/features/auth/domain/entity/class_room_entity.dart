import 'package:equatable/equatable.dart';

class ClassRoomEntity extends Equatable {
  final String? id;
  final String? roomName;
  final String? maxCapacity;
  final String? note;
  final List<dynamic>? currentClass;

  const ClassRoomEntity({
    this.id,
    this.roomName,
    this.maxCapacity,
    this.note,
    this.currentClass,
  });

  @override
  List<Object?> get props => [id, roomName, maxCapacity, note, currentClass];
}
