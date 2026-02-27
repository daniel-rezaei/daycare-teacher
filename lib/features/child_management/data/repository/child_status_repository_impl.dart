import 'package:injectable/injectable.dart';
import 'package:teacher_app/core/data_state.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/child_management/domain/repository/attendance_repository.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_status_aggregate_entity.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_repository.dart';
import 'package:teacher_app/features/child_management/domain/repository/child_status_repository.dart';
import 'package:teacher_app/features/child_management/domain/repository/class_transfer_request_repository.dart';
import 'package:teacher_app/features/child_management/services/local_absent_storage_service.dart';
import 'package:teacher_app/features/child_management/utils/child_status_logger.dart';

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
    childStatusLog('Repository: getChildrenStatus started classId=$classId');
    final childrenResult = await childRepository.getAllChildren();
    if (childrenResult is DataFailed) {
      childStatusLog('Repository: getChildren FAILED at children: ${childrenResult.error}', isError: true);
      return DataFailed(childrenResult.error ?? '');
    }
    childStatusLog('Repository: children OK count=${childrenResult.data?.length ?? 0}');

    final contactsResult = await childRepository.getAllContacts();
    if (contactsResult is DataFailed) {
      childStatusLog('Repository: getChildrenStatus FAILED at contacts: ${contactsResult.error}', isError: true);
      return DataFailed(contactsResult.error ?? '');
    }
    childStatusLog('Repository: contacts OK count=${contactsResult.data?.length ?? 0}');

    final attendanceResult = await attendanceRepository.getAttendanceByClassId(
      classId: classId,
    );
    if (attendanceResult is DataFailed) {
      childStatusLog('Repository: getChildrenStatus FAILED at attendance: ${attendanceResult.error}', isError: true);
      return DataFailed(attendanceResult.error ?? '');
    }
    childStatusLog('Repository: attendance OK count=${attendanceResult.data?.length ?? 0}');

    final transferResult =
        await classTransferRequestRepository.getTransferRequestsByClassId(
      classId: classId,
    );
    if (transferResult is DataFailed) {
      childStatusLog('Repository: getChildrenStatus FAILED at transferRequests: ${transferResult.error}', isError: true);
      return DataFailed(transferResult.error ?? '');
    }
    childStatusLog('Repository: transferRequests OK count=${transferResult.data?.length ?? 0}');

    final locallyAbsentIds =
        await LocalAbsentStorageService.getAbsentToday(classId);
    childStatusLog('Repository: localAbsent count=${locallyAbsentIds.length}');

    childStatusLog('Repository: getChildrenStatus SUCCESS');
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
