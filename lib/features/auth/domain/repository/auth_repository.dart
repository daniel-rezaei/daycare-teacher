import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';

abstract class AuthRepository {
  // دریافت کلاس ها
  Future<DataState<List<ClassRoomEntity>>> classRoom();

  // دریافت کارکنان هر کلاس
  Future<DataState<List<StaffClassEntity>>> staffClass();
}
