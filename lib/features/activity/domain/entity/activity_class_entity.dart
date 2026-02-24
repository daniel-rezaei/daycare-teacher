import 'package:equatable/equatable.dart';

class ActivityClassEntity extends Equatable {
  final String id;
  final String roomName;

  const ActivityClassEntity({
    required this.id,
    required this.roomName,
  });

  @override
  List<Object?> get props => [id, roomName];
}
