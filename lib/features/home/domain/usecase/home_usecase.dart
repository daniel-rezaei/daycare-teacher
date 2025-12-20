import 'package:injectable/injectable.dart';
import 'package:teacher_app/features/home/domain/repository/home_repository.dart';

@singleton
class HomeUsecase {
  final HomeRepository homeRepository;

  HomeUsecase(this.homeRepository);
}

