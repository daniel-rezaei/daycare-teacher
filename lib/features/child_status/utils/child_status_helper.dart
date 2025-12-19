import 'package:flutter/foundation.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

class ChildStatusHelper {
  ChildStatusHelper._();

  /// Get children in class filtered by active status and valid contact
  static List<ChildEntity> getChildrenInClass(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    // فیلتر Contacts با Role="child" و استخراج contact_id های آن‌ها
    final validChildContactIds = contacts
        .where((contact) => contact.role == 'child')
        .map((contact) => contact.id)
        .where((id) => id != null && id.isNotEmpty)
        .toSet();

    debugPrint('[CHILD_STATUS_DEBUG] Valid child contact IDs: $validChildContactIds');

    // فیلتر بچه‌هایی که contact_id آن‌ها در validChildContactIds موجود است
    final filtered = children.where((child) {
      final isActive = child.status == 'active';
      final hasValidContactId = child.contactId != null && child.contactId!.isNotEmpty;
      final contactExists = hasValidContactId && validChildContactIds.contains(child.contactId);

      final shouldInclude = isActive && hasValidContactId && contactExists;

      debugPrint(
        '[CHILD_STATUS_DEBUG] Child ${child.id}: primaryRoomId=${child.primaryRoomId}, '
        'isActive=$isActive, hasValidContactId=$hasValidContactId, '
        'contactExists=$contactExists, shouldInclude=$shouldInclude',
      );

      return shouldInclude;
    }).toList();

    debugPrint('[CHILD_STATUS_DEBUG] Filtered children count: ${filtered.length}');

    return filtered;
  }

  /// Check if child is present today
  static bool isChildPresent(
    String childId,
    List<AttendanceChildEntity> attendanceList,
  ) {
    // پیدا کردن attendance برای این بچه
    final childAttendance = attendanceList
        .where((attendance) => attendance.childId == childId)
        .toList();

    if (childAttendance.isEmpty) return false;

    // فیلتر کردن بر اساس تاریخ امروز
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayAttendance = childAttendance.where((attendance) {
      if (attendance.checkInAt == null || attendance.checkInAt!.isEmpty) {
        return false;
      }

      try {
        final checkInDate = DateTime.parse(attendance.checkInAt!);
        return checkInDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            checkInDate.isBefore(todayEnd);
      } catch (e) {
        debugPrint('[CHILD_STATUS_DEBUG] Error parsing checkInAt: ${attendance.checkInAt}, error: $e');
        return false;
      }
    }).toList();

    if (todayAttendance.isEmpty) return false;

    // آخرین attendance را بر اساس check_in_at پیدا می‌کنیم
    todayAttendance.sort((a, b) {
      final aTime = a.checkInAt ?? '';
      final bTime = b.checkInAt ?? '';
      return bTime.compareTo(aTime);
    });

    final latest = todayAttendance.first;
    // اگر check_in_at وجود دارد و check_out_at null است، یعنی حاضر است
    final isPresent = latest.checkInAt != null &&
        latest.checkInAt!.isNotEmpty &&
        (latest.checkOutAt == null || latest.checkOutAt!.isEmpty);

    debugPrint(
      '[CHILD_STATUS_DEBUG] Child $childId: checkInAt=${latest.checkInAt}, '
      'checkOutAt=${latest.checkOutAt}, isPresent=$isPresent',
    );

    return isPresent;
  }

  /// Get child attendance for today
  static AttendanceChildEntity? getChildAttendance(
    String childId,
    List<AttendanceChildEntity> attendanceList,
  ) {
    final now = DateTime.now();
    final todayAttendance = attendanceList
        .where((attendance) =>
            attendance.childId == childId &&
            attendance.checkInAt != null &&
            DateUtils.isSameDate(attendance.checkInAt!, now))
        .toList();

    if (todayAttendance.isEmpty) return null;

    todayAttendance.sort((a, b) {
      final aTime = a.checkInAt ?? '';
      final bTime = b.checkInAt ?? '';
      return bTime.compareTo(aTime);
    });

    return todayAttendance.first;
  }
}

