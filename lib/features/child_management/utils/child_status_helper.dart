import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/child_management/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

enum ChildAttendanceStatus { notArrived, present, checkedOut, absent }

class ChildStatusHelper {
  ChildStatusHelper._();

  static List<ChildEntity> getChildrenInClass(
    List<ChildEntity> children,
    List<ContactEntity> contacts, {
    required String? classId,
  }) {
    final validChildContactIds = contacts
        .where((contact) => contact.role == 'child')
        .map((contact) => contact.id)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    final filtered = children.where((child) {
      final isActive = child.status == 'active';
      final hasValidContactId =
          child.contactId != null && child.contactId!.isNotEmpty;
      final contactExists =
          hasValidContactId && validChildContactIds.contains(child.contactId);
      final isInClass =
          classId != null &&
          child.primaryRoomId != null &&
          child.primaryRoomId == classId;
      return isActive && hasValidContactId && contactExists && isInClass;
    }).toList();
    return filtered;
  }

  static bool isChildPresent(
    String childId,
    List<AttendanceChildEntity> attendanceList,
  ) {
    final childAttendance = attendanceList
        .where((attendance) => attendance.childId == childId)
        .toList();

    if (childAttendance.isEmpty) return false;

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayAttendance = childAttendance.where((attendance) {
      if (attendance.checkInAt == null || attendance.checkInAt!.isEmpty) {
        return false;
      }
      try {
        final checkInDateUtc = DateTime.parse(attendance.checkInAt!);
        final checkInDateLocal = checkInDateUtc.toLocal();
        return checkInDateLocal.isAfter(
                todayStart.subtract(const Duration(seconds: 1))) &&
            checkInDateLocal.isBefore(todayEnd);
      } catch (e) {
        return false;
      }
    }).toList();

    if (todayAttendance.isEmpty) return false;

    todayAttendance.sort((a, b) {
      final aTime = a.checkInAt ?? '';
      final bTime = b.checkInAt ?? '';
      return bTime.compareTo(aTime);
    });

    final latest = todayAttendance.first;
    return latest.checkInAt != null &&
        latest.checkInAt!.isNotEmpty &&
        (latest.checkOutAt == null || latest.checkOutAt!.isEmpty);
  }

  static AttendanceChildEntity? getChildAttendance(
    String childId,
    List<AttendanceChildEntity> attendanceList, {
    String? classId,
  }) {
    final now = DateTime.now();
    final todayAttendance = attendanceList.where((attendance) {
      if (attendance.childId == null ||
          attendance.checkInAt == null ||
          attendance.childId != childId) {
        return false;
      }
      if (classId != null && attendance.classId != classId) {
        return false;
      }
      return DateUtils.isSameDate(attendance.checkInAt!, now);
    }).toList();

    if (todayAttendance.isEmpty) return null;

    todayAttendance.sort((a, b) {
      final aTime = a.checkInAt ?? '';
      final bTime = b.checkInAt ?? '';
      return bTime.compareTo(aTime);
    });

    return todayAttendance.first;
  }

  static ChildAttendanceStatus getChildStatusToday({
    required String childId,
    required String classId,
    required List<AttendanceChildEntity> attendanceList,
    Set<String>? locallyAbsentChildIds,
  }) {
    final now = DateTime.now();

    final validTodayAttendance = attendanceList.where((attendance) {
      if (attendance.childId == null ||
          attendance.classId == null ||
          attendance.childId!.isEmpty ||
          attendance.classId!.isEmpty) {
        return false;
      }
      if (attendance.childId != childId || attendance.classId != classId) {
        return false;
      }
      if (attendance.checkInAt == null || attendance.checkInAt!.isEmpty) {
        return false;
      }
      return DateUtils.isSameDate(attendance.checkInAt!, now);
    }).toList();

    if (validTodayAttendance.isNotEmpty) {
      final hasActiveAttendance = validTodayAttendance.any(
        (attendance) =>
            attendance.checkOutAt == null || attendance.checkOutAt!.isEmpty,
      );
      if (hasActiveAttendance) {
        return ChildAttendanceStatus.present;
      }
      return ChildAttendanceStatus.checkedOut;
    }

    final isLocallyAbsent = locallyAbsentChildIds?.contains(childId) ?? false;
    if (isLocallyAbsent) {
      return ChildAttendanceStatus.absent;
    }
    return ChildAttendanceStatus.notArrived;
  }
}
