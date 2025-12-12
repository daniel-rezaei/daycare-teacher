import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/domain/repository/auth_repository.dart';

@singleton
class AuthUsecase {
  final AuthRepository authRepository;

  AuthUsecase(this.authRepository);

  // دریافت کلاس ها
  Future<DataState<List<ClassRoomEntity>>> classRoom() async {
    DataState<List<ClassRoomEntity>> dataState = await authRepository
        .classRoom();
    return dataState;
  }

  // دریافت کارکنان هر کلاس
  Future<DataState<List<StaffClassEntity>>> staffClass() async {
    return await authRepository.staffClass();
  }
}
