import 'package:flutter/foundation.dart';
import 'package:teacher_app/core/utils/date_utils.dart';
import 'package:teacher_app/features/attendance/domain/entity/attendance_child_entity.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

enum ChildAttendanceStatus {
  notArrived,
  present,
  checkedOut,
  absent,
}

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
  /// 
  /// Note: This method filters by childId and today's date only.
  /// For status determination, use [getChildStatusToday] which also filters by classId.
  static AttendanceChildEntity? getChildAttendance(
    String childId,
    List<AttendanceChildEntity> attendanceList, {
    String? classId,
  }) {
    final now = DateTime.now();
    final todayAttendance = attendanceList
        .where((attendance) {
          // بررسی معتبر بودن رکورد
          if (attendance.childId == null || 
              attendance.checkInAt == null ||
              attendance.childId != childId) {
            return false;
          }

          // اگر classId ارائه شده، بررسی تطابق
          if (classId != null && attendance.classId != classId) {
            return false;
          }

          // بررسی تطابق تاریخ با امروز
          return DateUtils.isSameDate(attendance.checkInAt!, now);
        })
        .toList();

    if (todayAttendance.isEmpty) return null;

    todayAttendance.sort((a, b) {
      final aTime = a.checkInAt ?? '';
      final bTime = b.checkInAt ?? '';
      return bTime.compareTo(aTime);
    });

    return todayAttendance.first;
  }

  /// Get child attendance status for today based on business logic
  /// 
  /// Returns:
  /// - [ChildAttendanceStatus.notArrived]: No valid attendance record for today and current class, and not marked as absent locally
  /// - [ChildAttendanceStatus.present]: Has attendance with check_in_at != null and check_out_at == null for today
  /// - [ChildAttendanceStatus.checkedOut]: Has attendance with both check_in_at and check_out_at != null for today
  /// - [ChildAttendanceStatus.absent]: No attendance record but marked as absent locally
  static ChildAttendanceStatus getChildStatusToday({
    required String childId,
    required String classId,
    required List<AttendanceChildEntity> attendanceList,
    Set<String>? locallyAbsentChildIds,
  }) {
    final now = DateTime.now();

    // فیلتر کردن attendance بر اساس:
    // 1. child_id == childId
    // 2. class_id == classId
    // 3. child_id != null و class_id != null
    // 4. تاریخ check_in_at برابر با امروز است
    final validTodayAttendance = attendanceList.where((attendance) {
      // بررسی معتبر بودن رکورد
      if (attendance.childId == null || 
          attendance.classId == null ||
          attendance.childId!.isEmpty ||
          attendance.classId!.isEmpty) {
        return false;
      }

      // بررسی تطابق child_id و class_id
      if (attendance.childId != childId || attendance.classId != classId) {
        return false;
      }

      // بررسی وجود check_in_at و تطابق تاریخ با امروز
      if (attendance.checkInAt == null || attendance.checkInAt!.isEmpty) {
        return false;
      }

      // بررسی اینکه تاریخ check_in_at برابر با امروز است
      if (!DateUtils.isSameDate(attendance.checkInAt!, now)) {
        return false;
      }

      return true;
    }).toList();

    // اگر رکورد attendance معتبری برای امروز وجود دارد
    if (validTodayAttendance.isNotEmpty) {
      debugPrint(
        '[CHILD_STATUS_DEBUG] Child $childId: Found ${validTodayAttendance.length} valid attendance(s) for today',
      );
      
      // بررسی اینکه آیا رکوردی با check_out_at == null وجود دارد
      final hasActiveAttendance = validTodayAttendance.any(
        (attendance) => attendance.checkOutAt == null || attendance.checkOutAt!.isEmpty,
      );

      if (hasActiveAttendance) {
        debugPrint(
          '[CHILD_STATUS_DEBUG] Child $childId: Has active attendance (check_out_at == null) -> present',
        );
        return ChildAttendanceStatus.present;
      }

      // اگر همه رکوردها check_out_at != null دارند
      debugPrint(
        '[CHILD_STATUS_DEBUG] Child $childId: All attendances have check_out_at -> checkedOut',
      );
      return ChildAttendanceStatus.checkedOut;
    }

    // اگر هیچ رکورد attendance معتبری وجود ندارد
    // بررسی اینکه آیا در لیست غایبین محلی است
    final isLocallyAbsent = locallyAbsentChildIds?.contains(childId) ?? false;
    
    if (isLocallyAbsent) {
      debugPrint(
        '[CHILD_STATUS_DEBUG] Child $childId: Marked as absent locally -> absent',
      );
      return ChildAttendanceStatus.absent;
    }

    debugPrint(
      '[CHILD_STATUS_DEBUG] Child $childId: No valid attendance for today and class $classId -> notArrived',
    );
    return ChildAttendanceStatus.notArrived;
  }
}

