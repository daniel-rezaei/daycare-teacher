import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/attendance/domain/repository/attendance_repository.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_status_aggregate_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_repository.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_status_repository.dart';
import 'package:teacher_app/features/child_management/domain/repository/class_transfer_request_repository.dart';
import 'package:teacher_app/features/child_management/services/local_absent_storage_service.dart';

@Singleton(as: ChildStatusRepository, env: [Env.prod])
class ChildStatusRepositoryImpl extends ChildStatusRepository {
  final ChildRepository childRepository;
  final AttendanceRepository attendanceRepository;
  final ClassTransferRequestRepository classTransferRequestRepository;

  ChildStatusRepositoryImpl(
    this.childRepository,
    this.attendanceRepository,
    this.classTransferRequestRepository,
  );

  @override
  Future<DataState<ChildStatusAggregateEntity>> getChildrenStatus(
    String classId,
  ) async {
    final childrenResult = await childRepository.getAllChildren();
    if (childrenResult is DataFailed) {
      return DataFailed(childrenResult.error ?? '');
    }

    final contactsResult = await childRepository.getAllContacts();
    if (contactsResult is DataFailed) {
      return DataFailed(contactsResult.error ?? '');
    }

    final attendanceResult = await attendanceRepository.getAttendanceByClassId(
      classId: classId,
    );
    if (attendanceResult is DataFailed) {
      return DataFailed(attendanceResult.error ?? '');
    }

    final transferResult =
        await classTransferRequestRepository.getTransferRequestsByClassId(
      classId: classId,
    );
    if (transferResult is DataFailed) {
      return DataFailed(transferResult.error ?? '');
    }

    final locallyAbsentIds =
        await LocalAbsentStorageService.getAbsentToday(classId);

    return DataSuccess(
      ChildStatusAggregateEntity(
        children: childrenResult.data ?? [],
        contacts: contactsResult.data ?? [],
        attendanceList: attendanceResult.data ?? [],
        transferRequests: transferResult.data ?? [],
        locallyAbsentChildIds: locallyAbsentIds,
      ),
    );
  }
}
