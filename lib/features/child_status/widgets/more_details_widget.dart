import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/child_status/utils/child_status_helper.dart';
import 'package:teacher_app/features/child_status/widgets/add_note_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/transfer_class_widget.dart';

class MoreDetailsWidget extends StatelessWidget {
  final String childId;
  final String classId; // Teacher's current class
  final String childCurrentClassId; // Child's current class (primaryRoomId)
  final String? childImage; // photoId
  final String childFirstName;
  final String childLastName;
  final ChildAttendanceStatus childAttendanceStatus;
  final String? attendanceId;

  const MoreDetailsWidget({
    super.key,
    required this.childId,
    required this.classId,
    required this.childCurrentClassId,
    required this.childFirstName,
    required this.childLastName,
    this.childImage,
    required this.childAttendanceStatus,
    this.attendanceId,
  });

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetWrapper(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderCheckOutWidget(isIcon: false, title: 'More Details'),
          const Divider(color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // بستن MoreDetailsWidget
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (context) => AddNoteWidget(
                    childId: childId,
                    classId: classId,
                    childImage: childImage,
                    childFirstName: childFirstName,
                    childLastName: childLastName,
                    childAttendanceStatus: childAttendanceStatus,
                    attendanceId: attendanceId,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 48,
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Add Note',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // بستن MoreDetailsWidget
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (context) => TransferClassWidget(
                  studentId: childId,
                  currentClassId: childCurrentClassId,
                ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 48,
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Transfer Class',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
