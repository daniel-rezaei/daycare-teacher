part of 'activity_bloc.dart';

sealed class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

/// بارگذاری لیست برنامه‌های یادگیری یک کلاس
class LoadLearningPlansEvent extends ActivityEvent {
  final String classId;

  const LoadLearningPlansEvent({required this.classId});

  @override
  List<Object?> get props => [classId];
}

/// بارگذاری جزئیات یک برنامه یادگیری
class LoadLearningPlanByIdEvent extends ActivityEvent {
  final String id;

  const LoadLearningPlanByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
