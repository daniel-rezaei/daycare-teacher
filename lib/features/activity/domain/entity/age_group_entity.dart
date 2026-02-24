import 'package:equatable/equatable.dart';

class AgeGroupEntity extends Equatable {
  final String id;
  final String name;
  final String? key;
  final int? minAgeMonths;
  final int? maxAgeMonths;

  const AgeGroupEntity({
    required this.id,
    required this.name,
    this.key,
    this.minAgeMonths,
    this.maxAgeMonths,
  });

  @override
  List<Object?> get props => [id, name, key, minAgeMonths, maxAgeMonths];
}
