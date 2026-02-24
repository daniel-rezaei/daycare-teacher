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
import 'package:teacher_app/features/activity/data/data_source/activity_accident_api.dart'
    as _i1024;
import 'package:teacher_app/features/activity/data/data_source/activity_bathroom_api.dart'
    as _i255;
import 'package:teacher_app/features/activity/data/data_source/activity_drinks_api.dart'
    as _i281;
import 'package:teacher_app/features/activity/data/data_source/activity_incident_api.dart'
    as _i343;
import 'package:teacher_app/features/activity/data/data_source/activity_meals_api.dart'
    as _i491;
import 'package:teacher_app/features/activity/data/data_source/activity_mood_api.dart'
    as _i981;
import 'package:teacher_app/features/activity/data/data_source/activity_observation_api.dart'
    as _i791;
import 'package:teacher_app/features/activity/data/data_source/activity_play_api.dart'
    as _i1025;
import 'package:teacher_app/features/activity/data/data_source/activity_sleep_api.dart'
    as _i765;
import 'package:teacher_app/features/activity/data/data_source/file_upload_api.dart'
    as _i474;
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart'
    as _i758;
import 'package:teacher_app/features/activity/data/repository/activity_repository_impl.dart'
    as _i835;
import 'package:teacher_app/features/activity/data/repository/file_upload_repository_impl.dart'
    as _i287;
import 'package:teacher_app/features/activity/domain/repository/activity_repository.dart'
    as _i102;
import 'package:teacher_app/features/activity/domain/repository/file_upload_repository.dart'
    as _i124;
import 'package:teacher_app/features/activity/domain/usecase/activity_usecase.dart'
    as _i962;
import 'package:teacher_app/features/activity/domain/usecase/file_upload_usecase.dart'
    as _i750;
import 'package:teacher_app/features/activity/presentation/bloc/activity_bloc.dart'
    as _i1041;
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
import 'package:teacher_app/features/child_management/data/data_source/attendance_api.dart'
    as _i148;
import 'package:teacher_app/features/child_management/data/data_source/child_api.dart'
    as _i712;
import 'package:teacher_app/features/child_management/data/data_source/child_emergency_contact_api.dart'
    as _i644;
import 'package:teacher_app/features/child_management/data/data_source/child_guardian_api.dart'
    as _i548;
import 'package:teacher_app/features/child_management/data/data_source/class_transfer_request_api.dart'
    as _i6;
import 'package:teacher_app/features/child_management/data/repository/attendance_repository_impl.dart'
    as _i200;
import 'package:teacher_app/features/child_management/data/repository/child_emergency_contact_repository_impl.dart'
    as _i428;
import 'package:teacher_app/features/child_management/data/repository/child_guardian_repository_impl.dart'
    as _i361;
import 'package:teacher_app/features/child_management/data/repository/child_repository_impl.dart'
    as _i796;
import 'package:teacher_app/features/child_management/data/repository/child_status_repository_impl.dart'
    as _i50;
import 'package:teacher_app/features/child_management/data/repository/class_transfer_request_repository_impl.dart'
    as _i663;
import 'package:teacher_app/features/child_management/domain/repository/attendance_repository.dart'
    as _i33;
import 'package:teacher_app/features/child_management/domain/repository/child_emergency_contact_repository.dart'
    as _i789;
import 'package:teacher_app/features/child_management/domain/repository/child_guardian_repository.dart'
    as _i442;
import 'package:teacher_app/features/child_management/domain/repository/child_repository.dart'
    as _i876;
import 'package:teacher_app/features/child_management/domain/repository/child_status_repository.dart'
    as _i677;
import 'package:teacher_app/features/child_management/domain/repository/class_transfer_request_repository.dart'
    as _i309;
import 'package:teacher_app/features/child_management/domain/usecase/attendance_usecase.dart'
    as _i691;
import 'package:teacher_app/features/child_management/domain/usecase/child_emergency_contact_usecase.dart'
    as _i213;
import 'package:teacher_app/features/child_management/domain/usecase/child_guardian_usecase.dart'
    as _i497;
import 'package:teacher_app/features/child_management/domain/usecase/child_status_usecase.dart'
    as _i618;
import 'package:teacher_app/features/child_management/domain/usecase/child_usecase.dart'
    as _i828;
import 'package:teacher_app/features/child_management/domain/usecase/class_transfer_request_usecase.dart'
    as _i265;
import 'package:teacher_app/features/child_management/presentation/bloc/attendance_bloc.dart'
    as _i912;
import 'package:teacher_app/features/child_management/presentation/bloc/child_bloc.dart'
    as _i148;
import 'package:teacher_app/features/child_management/presentation/bloc/child_emergency_contact_bloc.dart'
    as _i1072;
import 'package:teacher_app/features/child_management/presentation/bloc/child_guardian_bloc.dart'
    as _i768;
import 'package:teacher_app/features/child_management/presentation/bloc/child_management_bloc.dart'
    as _i976;
import 'package:teacher_app/features/child_management/presentation/bloc/child_profile_bloc.dart'
    as _i765;
import 'package:teacher_app/features/child_management/presentation/bloc/class_transfer_request_bloc.dart'
    as _i192;
import 'package:teacher_app/features/home/data/data_source/home_api.dart'
    as _i618;
import 'package:teacher_app/features/home/data/repository/home_repository_impl.dart'
    as _i359;
import 'package:teacher_app/features/home/domain/repository/home_repository.dart'
    as _i78;
import 'package:teacher_app/features/home/domain/usecase/home_usecase.dart'
    as _i777;
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart'
    as _i493;
import 'package:teacher_app/features/personal_information/data/data_source/staff_schedule_api.dart'
    as _i354;
import 'package:teacher_app/features/personal_information/data/repository/staff_schedule_repository_impl.dart'
    as _i996;
import 'package:teacher_app/features/personal_information/domain/repository/staff_schedule_repository.dart'
    as _i314;
import 'package:teacher_app/features/personal_information/domain/usecase/staff_schedule_usecase.dart'
    as _i887;
import 'package:teacher_app/features/personal_information/presentation/bloc/staff_schedule_bloc.dart'
    as _i468;
import 'package:teacher_app/features/pickup_authorization/data/data_source/pickup_authorization_api.dart'
    as _i997;
import 'package:teacher_app/features/pickup_authorization/data/repository/pickup_authorization_repository_impl.dart'
    as _i592;
import 'package:teacher_app/features/pickup_authorization/domain/repository/pickup_authorization_repository.dart'
    as _i520;
import 'package:teacher_app/features/pickup_authorization/domain/usecase/pickup_authorization_usecase.dart'
    as _i1027;
import 'package:teacher_app/features/pickup_authorization/presentation/bloc/pickup_authorization_bloc.dart'
    as _i1025;
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
import 'package:teacher_app/features/staff_attendance/data/data_source/staff_attendance_api.dart'
    as _i45;
import 'package:teacher_app/features/staff_attendance/data/repository/staff_attendance_repository_impl.dart'
    as _i370;
import 'package:teacher_app/features/staff_attendance/domain/repository/staff_attendance_repository.dart'
    as _i910;
import 'package:teacher_app/features/staff_attendance/domain/usecase/staff_attendance_usecase.dart'
    as _i18;
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart'
    as _i264;

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
    gh.singleton<_i1024.ActivityAccidentApi>(
      () => _i1024.ActivityAccidentApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i255.ActivityBathroomApi>(
      () => _i255.ActivityBathroomApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i281.ActivityDrinksApi>(
      () => _i281.ActivityDrinksApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i343.ActivityIncidentApi>(
      () => _i343.ActivityIncidentApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i491.ActivityMealsApi>(
      () => _i491.ActivityMealsApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i981.ActivityMoodApi>(
      () => _i981.ActivityMoodApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i791.ActivityObservationApi>(
      () => _i791.ActivityObservationApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i1025.ActivityPlayApi>(
      () => _i1025.ActivityPlayApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i765.ActivitySleepApi>(
      () => _i765.ActivitySleepApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i474.FileUploadApi>(
      () => _i474.FileUploadApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i758.LearningPlanApi>(
      () => _i758.LearningPlanApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i59.AuthApi>(() => _i59.AuthApi(gh<_i361.Dio>()));
    gh.singleton<_i148.AttendanceApi>(
      () => _i148.AttendanceApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i712.ChildApi>(() => _i712.ChildApi(gh<_i361.Dio>()));
    gh.singleton<_i644.ChildEmergencyContactApi>(
      () => _i644.ChildEmergencyContactApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i548.ChildGuardianApi>(
      () => _i548.ChildGuardianApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i6.ClassTransferRequestApi>(
      () => _i6.ClassTransferRequestApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i618.HomeApi>(() => _i618.HomeApi(gh<_i361.Dio>()));
    gh.singleton<_i354.StaffScheduleApi>(
      () => _i354.StaffScheduleApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i997.PickupAuthorizationApi>(
      () => _i997.PickupAuthorizationApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i595.ProfileApi>(() => _i595.ProfileApi(gh<_i361.Dio>()));
    gh.singleton<_i45.StaffAttendanceApi>(
      () => _i45.StaffAttendanceApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i910.StaffAttendanceRepository>(
      () => _i370.StaffAttendanceRepositoryImpl(gh<_i45.StaffAttendanceApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i309.ClassTransferRequestRepository>(
      () => _i663.ClassTransferRequestRepositoryImpl(
        gh<_i6.ClassTransferRequestApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i789.ChildEmergencyContactRepository>(
      () => _i428.ChildEmergencyContactRepositoryImpl(
        gh<_i644.ChildEmergencyContactApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i314.StaffScheduleRepository>(
      () => _i996.StaffScheduleRepositoryImpl(gh<_i354.StaffScheduleApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i33.AttendanceRepository>(
      () => _i200.AttendanceRepositoryImpl(gh<_i148.AttendanceApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i876.ChildRepository>(
      () => _i796.ChildRepositoryImpl(
        gh<_i712.ChildApi>(),
        gh<_i595.ProfileApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i78.HomeRepository>(
      () => _i359.HomeRepositoryImpl(gh<_i618.HomeApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i442.ChildGuardianRepository>(
      () => _i361.ChildGuardianRepositoryImpl(gh<_i548.ChildGuardianApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i275.AuthRepository>(
      () => _i733.AuthRepositoryImpl(gh<_i59.AuthApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i520.PickupAuthorizationRepository>(
      () => _i592.PickupAuthorizationRepositoryImpl(
        gh<_i997.PickupAuthorizationApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i497.ChildGuardianUsecase>(
      () => _i497.ChildGuardianUsecase(gh<_i442.ChildGuardianRepository>()),
    );
    gh.singleton<_i828.ChildUsecase>(
      () => _i828.ChildUsecase(gh<_i876.ChildRepository>()),
    );
    gh.singleton<_i18.StaffAttendanceUsecase>(
      () => _i18.StaffAttendanceUsecase(gh<_i910.StaffAttendanceRepository>()),
    );
    gh.singleton<_i265.ClassTransferRequestUsecase>(
      () => _i265.ClassTransferRequestUsecase(
        gh<_i309.ClassTransferRequestRepository>(),
      ),
    );
    gh.singleton<_i887.StaffScheduleUsecase>(
      () => _i887.StaffScheduleUsecase(gh<_i314.StaffScheduleRepository>()),
    );
    gh.singleton<_i677.ChildStatusRepository>(
      () => _i50.ChildStatusRepositoryImpl(
        gh<_i876.ChildRepository>(),
        gh<_i33.AttendanceRepository>(),
        gh<_i309.ClassTransferRequestRepository>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i124.FileUploadRepository>(
      () => _i287.FileUploadRepositoryImpl(gh<_i474.FileUploadApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i102.ActivityRepository>(
      () => _i835.ActivityRepositoryImpl(gh<_i758.LearningPlanApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i962.ActivityUsecase>(
      () => _i962.ActivityUsecase(gh<_i102.ActivityRepository>()),
    );
    gh.factory<_i264.StaffAttendanceBloc>(
      () => _i264.StaffAttendanceBloc(gh<_i18.StaffAttendanceUsecase>()),
    );
    gh.singleton<_i1027.PickupAuthorizationUsecase>(
      () => _i1027.PickupAuthorizationUsecase(
        gh<_i520.PickupAuthorizationRepository>(),
      ),
    );
    gh.singleton<_i59.ProfileRepository>(
      () => _i248.ProfileRepositoryImpl(gh<_i595.ProfileApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i1069.AuthUsecase>(
      () => _i1069.AuthUsecase(gh<_i275.AuthRepository>()),
    );
    gh.singleton<_i213.ChildEmergencyContactUsecase>(
      () => _i213.ChildEmergencyContactUsecase(
        gh<_i789.ChildEmergencyContactRepository>(),
      ),
    );
    gh.singleton<_i691.AttendanceUsecase>(
      () => _i691.AttendanceUsecase(gh<_i33.AttendanceRepository>()),
    );
    gh.singleton<_i618.ChildStatusUsecase>(
      () => _i618.ChildStatusUsecase(gh<_i677.ChildStatusRepository>()),
    );
    gh.factory<_i468.StaffScheduleBloc>(
      () => _i468.StaffScheduleBloc(gh<_i887.StaffScheduleUsecase>()),
    );
    gh.factory<_i445.AuthBloc>(() => _i445.AuthBloc(gh<_i1069.AuthUsecase>()));
    gh.factory<_i1041.ActivityBloc>(
      () => _i1041.ActivityBloc(gh<_i962.ActivityUsecase>()),
    );
    gh.factory<_i976.ChildStatusModuleBloc>(
      () => _i976.ChildStatusModuleBloc(gh<_i618.ChildStatusUsecase>()),
    );
    gh.factory<_i768.ChildGuardianBloc>(
      () => _i768.ChildGuardianBloc(gh<_i497.ChildGuardianUsecase>()),
    );
    gh.singleton<_i777.HomeUsecase>(
      () => _i777.HomeUsecase(gh<_i78.HomeRepository>()),
    );
    gh.singleton<_i750.FileUploadUsecase>(
      () => _i750.FileUploadUsecase(gh<_i124.FileUploadRepository>()),
    );
    gh.factory<_i148.ChildBloc>(
      () => _i148.ChildBloc(gh<_i828.ChildUsecase>()),
    );
    gh.factory<_i765.ChildProfileBloc>(
      () => _i765.ChildProfileBloc(gh<_i828.ChildUsecase>()),
    );
    gh.factory<_i1072.ChildEmergencyContactBloc>(
      () => _i1072.ChildEmergencyContactBloc(
        gh<_i213.ChildEmergencyContactUsecase>(),
      ),
    );
    gh.factory<_i912.AttendanceBloc>(
      () => _i912.AttendanceBloc(gh<_i691.AttendanceUsecase>()),
    );
    gh.factory<_i192.ClassTransferRequestBloc>(
      () => _i192.ClassTransferRequestBloc(
        gh<_i265.ClassTransferRequestUsecase>(),
      ),
    );
    gh.singleton<_i1012.ProfileUsecase>(
      () => _i1012.ProfileUsecase(gh<_i59.ProfileRepository>()),
    );
    gh.factory<_i1025.PickupAuthorizationBloc>(
      () => _i1025.PickupAuthorizationBloc(
        gh<_i1027.PickupAuthorizationUsecase>(),
      ),
    );
    gh.factory<_i224.ProfileBloc>(
      () => _i224.ProfileBloc(gh<_i1012.ProfileUsecase>()),
    );
    gh.factory<_i493.HomeBloc>(() => _i493.HomeBloc(gh<_i777.HomeUsecase>()));
    return this;
  }
}

class _$DioModule extends _i567.DioModule {}
