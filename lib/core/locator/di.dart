import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/locator/di.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies({required String environment}) async =>
    getIt.init(environment: environment);

abstract class Env {
  static const mock = 'mock';
  static const dev = 'dev';
  static const prod = 'prod';
}
