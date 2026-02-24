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
import 'package:teacher_app/features/activity/data/data_source/learning_plan_api.dart'
    as _i758;
import 'package:teacher_app/features/activity/data/repository/activity_repository_impl.dart'
    as _i835;
import 'package:teacher_app/features/activity/domain/repository/activity_repository.dart'
    as _i102;
import 'package:teacher_app/features/activity/domain/usecase/activity_usecase.dart'
    as _i962;
import 'package:teacher_app/features/activity/presentation/bloc/activity_bloc.dart'
    as _i1041;
import 'package:teacher_app/features/attendance/data/data_source/attendance_api.dart'
    as _i472;
import 'package:teacher_app/features/attendance/data/repository/attendance_repository_impl.dart'
    as _i954;
import 'package:teacher_app/features/attendance/domain/repository/attendance_repository.dart'
    as _i570;
import 'package:teacher_app/features/attendance/domain/usecase/attendance_usecase.dart'
    as _i905;
import 'package:teacher_app/features/attendance/presentation/bloc/attendance_bloc.dart'
    as _i811;
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
import 'package:teacher_app/features/child_status_module/data/data_source/child_api.dart'
    as _i491;
import 'package:teacher_app/features/child_status_module/data/data_source/child_emergency_contact_api.dart'
    as _i82;
import 'package:teacher_app/features/child_status_module/data/data_source/child_guardian_api.dart'
    as _i200;
import 'package:teacher_app/features/child_status_module/data/data_source/class_transfer_request_api.dart'
    as _i644;
import 'package:teacher_app/features/child_status_module/data/repository/child_emergency_contact_repository_impl.dart'
    as _i1008;
import 'package:teacher_app/features/child_status_module/data/repository/child_guardian_repository_impl.dart'
    as _i716;
import 'package:teacher_app/features/child_status_module/data/repository/child_repository_impl.dart'
    as _i614;
import 'package:teacher_app/features/child_status_module/data/repository/child_status_repository_impl.dart'
    as _i100;
import 'package:teacher_app/features/child_status_module/data/repository/class_transfer_request_repository_impl.dart'
    as _i430;
import 'package:teacher_app/features/child_status_module/domain/repository/child_emergency_contact_repository.dart'
    as _i849;
import 'package:teacher_app/features/child_status_module/domain/repository/child_guardian_repository.dart'
    as _i703;
import 'package:teacher_app/features/child_status_module/domain/repository/child_repository.dart'
    as _i642;
import 'package:teacher_app/features/child_status_module/domain/repository/child_status_repository.dart'
    as _i339;
import 'package:teacher_app/features/child_status_module/domain/repository/class_transfer_request_repository.dart'
    as _i186;
import 'package:teacher_app/features/child_status_module/domain/usecase/child_emergency_contact_usecase.dart'
    as _i1055;
import 'package:teacher_app/features/child_status_module/domain/usecase/child_guardian_usecase.dart'
    as _i534;
import 'package:teacher_app/features/child_status_module/domain/usecase/child_status_usecase.dart'
    as _i364;
import 'package:teacher_app/features/child_status_module/domain/usecase/child_usecase.dart'
    as _i659;
import 'package:teacher_app/features/child_status_module/domain/usecase/class_transfer_request_usecase.dart'
    as _i311;
import 'package:teacher_app/features/child_status_module/presentation/bloc/child_bloc.dart'
    as _i1049;
import 'package:teacher_app/features/child_status_module/presentation/bloc/child_emergency_contact_bloc.dart'
    as _i853;
import 'package:teacher_app/features/child_status_module/presentation/bloc/child_guardian_bloc.dart'
    as _i501;
import 'package:teacher_app/features/child_status_module/presentation/bloc/child_profile_bloc.dart'
    as _i546;
import 'package:teacher_app/features/child_status_module/presentation/bloc/child_status_module_bloc.dart'
    as _i630;
import 'package:teacher_app/features/child_status_module/presentation/bloc/class_transfer_request_bloc.dart'
    as _i690;
import 'package:teacher_app/features/file_upload/data/data_source/file_upload_api.dart'
    as _i357;
import 'package:teacher_app/features/file_upload/data/repository/file_upload_repository_impl.dart'
    as _i355;
import 'package:teacher_app/features/file_upload/domain/repository/file_upload_repository.dart'
    as _i606;
import 'package:teacher_app/features/file_upload/domain/usecase/file_upload_usecase.dart'
    as _i299;
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
import 'package:teacher_app/features/staff_schedule/data/data_source/staff_schedule_api.dart'
    as _i565;
import 'package:teacher_app/features/staff_schedule/data/repository/staff_schedule_repository_impl.dart'
    as _i162;
import 'package:teacher_app/features/staff_schedule/domain/repository/staff_schedule_repository.dart'
    as _i1057;
import 'package:teacher_app/features/staff_schedule/domain/usecase/staff_schedule_usecase.dart'
    as _i471;
import 'package:teacher_app/features/staff_schedule/presentation/bloc/staff_schedule_bloc.dart'
    as _i606;

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
    gh.singleton<_i758.LearningPlanApi>(
      () => _i758.LearningPlanApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i472.AttendanceApi>(
      () => _i472.AttendanceApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i59.AuthApi>(() => _i59.AuthApi(gh<_i361.Dio>()));
    gh.singleton<_i491.ChildApi>(() => _i491.ChildApi(gh<_i361.Dio>()));
    gh.singleton<_i82.ChildEmergencyContactApi>(
      () => _i82.ChildEmergencyContactApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i200.ChildGuardianApi>(
      () => _i200.ChildGuardianApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i644.ClassTransferRequestApi>(
      () => _i644.ClassTransferRequestApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i357.FileUploadApi>(
      () => _i357.FileUploadApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i618.HomeApi>(() => _i618.HomeApi(gh<_i361.Dio>()));
    gh.singleton<_i997.PickupAuthorizationApi>(
      () => _i997.PickupAuthorizationApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i595.ProfileApi>(() => _i595.ProfileApi(gh<_i361.Dio>()));
    gh.singleton<_i45.StaffAttendanceApi>(
      () => _i45.StaffAttendanceApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i565.StaffScheduleApi>(
      () => _i565.StaffScheduleApi(gh<_i361.Dio>()),
    );
    gh.singleton<_i849.ChildEmergencyContactRepository>(
      () => _i1008.ChildEmergencyContactRepositoryImpl(
        gh<_i82.ChildEmergencyContactApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i910.StaffAttendanceRepository>(
      () => _i370.StaffAttendanceRepositoryImpl(gh<_i45.StaffAttendanceApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i606.FileUploadRepository>(
      () => _i355.FileUploadRepositoryImpl(gh<_i357.FileUploadApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i1057.StaffScheduleRepository>(
      () => _i162.StaffScheduleRepositoryImpl(gh<_i565.StaffScheduleApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i78.HomeRepository>(
      () => _i359.HomeRepositoryImpl(gh<_i618.HomeApi>()),
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
    gh.singleton<_i299.FileUploadUsecase>(
      () => _i299.FileUploadUsecase(gh<_i606.FileUploadRepository>()),
    );
    gh.singleton<_i18.StaffAttendanceUsecase>(
      () => _i18.StaffAttendanceUsecase(gh<_i910.StaffAttendanceRepository>()),
    );
    gh.singleton<_i642.ChildRepository>(
      () => _i614.ChildRepositoryImpl(
        gh<_i491.ChildApi>(),
        gh<_i595.ProfileApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i1055.ChildEmergencyContactUsecase>(
      () => _i1055.ChildEmergencyContactUsecase(
        gh<_i849.ChildEmergencyContactRepository>(),
      ),
    );
    gh.singleton<_i102.ActivityRepository>(
      () => _i835.ActivityRepositoryImpl(gh<_i758.LearningPlanApi>()),
      registerFor: {_prod},
    );
    gh.singleton<_i186.ClassTransferRequestRepository>(
      () => _i430.ClassTransferRequestRepositoryImpl(
        gh<_i644.ClassTransferRequestApi>(),
      ),
      registerFor: {_prod},
    );
    gh.singleton<_i962.ActivityUsecase>(
      () => _i962.ActivityUsecase(gh<_i102.ActivityRepository>()),
    );
    gh.singleton<_i570.AttendanceRepository>(
      () => _i954.AttendanceRepositoryImpl(gh<_i472.AttendanceApi>()),
      registerFor: {_prod},
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
    gh.singleton<_i471.StaffScheduleUsecase>(
      () => _i471.StaffScheduleUsecase(gh<_i1057.StaffScheduleRepository>()),
    );
    gh.singleton<_i339.ChildStatusRepository>(
      () => _i100.ChildStatusRepositoryImpl(
        gh<_i642.ChildRepository>(),
        gh<_i570.AttendanceRepository>(),
        gh<_i186.ClassTransferRequestRepository>(),
      ),
      registerFor: {_prod},
    );
    gh.factory<_i853.ChildEmergencyContactBloc>(
      () => _i853.ChildEmergencyContactBloc(
        gh<_i1055.ChildEmergencyContactUsecase>(),
      ),
    );
    gh.singleton<_i703.ChildGuardianRepository>(
      () => _i716.ChildGuardianRepositoryImpl(gh<_i200.ChildGuardianApi>()),
      registerFor: {_prod},
    );
    gh.factory<_i445.AuthBloc>(() => _i445.AuthBloc(gh<_i1069.AuthUsecase>()));
    gh.factory<_i1041.ActivityBloc>(
      () => _i1041.ActivityBloc(gh<_i962.ActivityUsecase>()),
    );
    gh.factory<_i606.StaffScheduleBloc>(
      () => _i606.StaffScheduleBloc(gh<_i471.StaffScheduleUsecase>()),
    );
    gh.singleton<_i777.HomeUsecase>(
      () => _i777.HomeUsecase(gh<_i78.HomeRepository>()),
    );
    gh.singleton<_i659.ChildUsecase>(
      () => _i659.ChildUsecase(gh<_i642.ChildRepository>()),
    );
    gh.singleton<_i905.AttendanceUsecase>(
      () => _i905.AttendanceUsecase(gh<_i570.AttendanceRepository>()),
    );
    gh.singleton<_i534.ChildGuardianUsecase>(
      () => _i534.ChildGuardianUsecase(gh<_i703.ChildGuardianRepository>()),
    );
    gh.factory<_i1049.ChildBloc>(
      () => _i1049.ChildBloc(gh<_i659.ChildUsecase>()),
    );
    gh.factory<_i546.ChildProfileBloc>(
      () => _i546.ChildProfileBloc(gh<_i659.ChildUsecase>()),
    );
    gh.factory<_i501.ChildGuardianBloc>(
      () => _i501.ChildGuardianBloc(gh<_i534.ChildGuardianUsecase>()),
    );
    gh.singleton<_i364.ChildStatusUsecase>(
      () => _i364.ChildStatusUsecase(gh<_i339.ChildStatusRepository>()),
    );
    gh.singleton<_i1012.ProfileUsecase>(
      () => _i1012.ProfileUsecase(gh<_i59.ProfileRepository>()),
    );
    gh.singleton<_i311.ClassTransferRequestUsecase>(
      () => _i311.ClassTransferRequestUsecase(
        gh<_i186.ClassTransferRequestRepository>(),
      ),
    );
    gh.factory<_i811.AttendanceBloc>(
      () => _i811.AttendanceBloc(gh<_i905.AttendanceUsecase>()),
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
    gh.factory<_i690.ClassTransferRequestBloc>(
      () => _i690.ClassTransferRequestBloc(
        gh<_i311.ClassTransferRequestUsecase>(),
      ),
    );
    gh.factory<_i630.ChildStatusModuleBloc>(
      () => _i630.ChildStatusModuleBloc(gh<_i364.ChildStatusUsecase>()),
    );
    return this;
  }
}

class _$DioModule extends _i567.DioModule {}
