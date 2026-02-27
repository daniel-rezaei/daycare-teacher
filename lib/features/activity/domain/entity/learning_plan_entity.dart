import 'package:equatable/equatable.dart';

class LearningPlanEntity extends Equatable {
  final String id;
  final String title;
  final String startDate;
  final String endDate;
  final String? categoryId;
  final String categoryName;
  final String? ageGroupId;
  final String ageBandName;
  final String? classId;
  final String roomName;
  final String? videoLink;
  final List<String> tags;
  final String? description;
  // Optional attached file from API (`file` relation)
  final String? fileId;
  final String? fileName;
  final String? fileUrl;

  const LearningPlanEntity({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.categoryId,
    this.categoryName = '',
    this.ageGroupId,
    this.ageBandName = '',
    this.classId,
    this.roomName = '',
    this.videoLink,
    this.tags = const [],
    this.description,
    this.fileId,
    this.fileName,
    this.fileUrl,
  });

  String get dateRangeDisplay => '$startDate - $endDate';

  @override
  List<Object?> get props => [
        id,
        title,
        startDate,
        endDate,
        categoryId,
        categoryName,
        ageGroupId,
        ageBandName,
        classId,
        roomName,
        videoLink,
        tags,
        description,
        fileId,
        fileName,
        fileUrl,
      ];
}
