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
  Future<DataState<List<StaffClassEntity>>> staffClass({
    required String classId,
  }) async {
    return await authRepository.staffClass(classId: classId);
  }

  // دریافت class_id بر اساس contact_id
  Future<DataState<String>> getClassIdByContactId({
    required String contactId,
  }) async {
    return await authRepository.getClassIdByContactId(contactId: contactId);
  }

  // دریافت contact_id و class_id بر اساس email
  Future<DataState<Map<String, String>>> getContactIdAndClassIdByEmail({
    required String email,
  }) async {
    return await authRepository.getContactIdAndClassIdByEmail(email: email);
  }
}
