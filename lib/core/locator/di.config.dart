// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:teacher_app/core/http_client.dart' as _i567;
import 'package:teacher_app/features/auth/data/data_source/auth_api.dart'
    as _i59;
import 'package:teacher_app/features/auth/data/repository/auth_repository_impl.dart'
    as _i733;
import 'package:teacher_app/features/auth/domain/repository/auth_repository.dart'
    as _i275;
import 'package:teacher_app/features/auth/domain/usecase/auth_usecase.dart'
    as _i1069;
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart'
    as _i445;
import 'package:teacher_app/features/child/data/data_source/child_api.dart'
    as _i1069;
import 'package:teacher_app/features/child/data/repository/child_repository_impl.dart'
    as _i580;
import 'package:teacher_app/features/child/domain/repository/child_repository.dart'
    as _i551;
import 'package:teacher_app/features/child/domain/usecase/child_usecase.dart'
    as _i68;
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart'
    as _i135;
import 'package:teacher_app/features/event/data/data_source/event_api.dart'
    as _i99;
import 'package:teacher_app/features/event/data/repository/event_repository_impl.dart'
    as _i167;
import 'package:teacher_app/features/event/domain/repository/event_repository.dart'
    as _i784;
import 'package:teacher_app/features/event/domain/usecase/event_usecase.dart'
    as _i695;
import 'package:teacher_app/features/event/presentation/bloc/event_bloc.dart'
    as _i795;
import 'package:teacher_app/features/profile/data/data_source/profile_api.dart'
    as _i595;
import 'package:teacher_app/features/profile/data/repository/profile_repository_impl.dart'
    as _i248;
import 'package:teacher_app/features/profile/domain/repository/profile_repository.dart'
    as _i59;
import 'package:teacher_app/features/profile/domain/usecase/profile_usecase.dart'
    as _i1012;
import 'package:teacher_app/features/profile/presentation/bloc/profile_bloc.dart'
    as _i224;

const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio());
    gh.singleton<_i59.AuthApi>(() => _i59.AuthApi(gh<_i361.Dio>()));
    gh.singleton<_i1069.ChildApi>(() => _i1069.ChildApi(gh<_i361.Dio>()));
    gh.singleton<_i99.EventApi>(() => _i99.EventApi(gh<_i361.Dio>()));
    gh.singleton<_i595.ProfileApi>(() => _i595.ProfileApi(gh<_i361.Dio>()));
    gh.singleton<_i275.AuthRepository>(
      () => _i733.AuthRepositoryImpl(gh<_i59.AuthApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i784.EventRepository>(
      () => _i167.EventRepositoryImpl(gh<_i99.EventApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i59.ProfileRepository>(
      () => _i248.ProfileRepositoryImpl(gh<_i595.ProfileApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i551.ChildRepository>(
      () => _i580.ChildRepositoryImpl(
        gh<_i1069.ChildApi>(),
        gh<_i595.ProfileApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i1069.AuthUsecase>(
      () => _i1069.AuthUsecase(gh<_i275.AuthRepository>()),
    );
    gh.singleton<_i695.EventUsecase>(
      () => _i695.EventUsecase(gh<_i784.EventRepository>()),
    );
    gh.factory<_i445.AuthBloc>(() => _i445.AuthBloc(gh<_i1069.AuthUsecase>()));
    gh.singleton<_i68.ChildUsecase>(
      () => _i68.ChildUsecase(gh<_i551.ChildRepository>()),
    );
    gh.singleton<_i1012.ProfileUsecase>(
      () => _i1012.ProfileUsecase(gh<_i59.ProfileRepository>()),
    );
    gh.factory<_i135.ChildBloc>(() => _i135.ChildBloc(gh<_i68.ChildUsecase>()));
    gh.factory<_i795.EventBloc>(
      () => _i795.EventBloc(gh<_i695.EventUsecase>()),
    );
    gh.factory<_i224.ProfileBloc>(
      () => _i224.ProfileBloc(gh<_i1012.ProfileUsecase>()),
    );
    return this;
  }
}

class _$DioModule extends _i567.DioModule {}
