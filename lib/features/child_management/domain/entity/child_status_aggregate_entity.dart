import 'package:equatable/equatable.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/class_transfer_request_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

/// دادهٔ تجمیعی برای صفحه Child Status (لیست بچه‌ها با وضعیت حضور و درخواست انتقال).
class ChildStatusAggregateEntity extends Equatable {
  final List<ChildEntity> children;
  final List<ContactEntity> contacts;
  final List<AttendanceChildEntity> attendanceList;
  final List<ClassTransferRequestEntity> transferRequests;
  final Set<String> locallyAbsentChildIds;

  const ChildStatusAggregateEntity({
    required this.children,
    required this.contacts,
    required this.attendanceList,
    required this.transferRequests,
    required this.locallyAbsentChildIds,
  });

  @override
  List<Object?> get props => [
        children,
        contacts,
        attendanceList,
        transferRequests,
        locallyAbsentChildIds,
      ];
}
