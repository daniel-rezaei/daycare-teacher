import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/child_status/widgets/add_note_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/transfer_class_widget.dart';

class MoreDetailsWidget extends StatelessWidget {
  const MoreDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetWrapper(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderCheckOut(isIcon: false, title: 'More Details'),
          const Divider(color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (context) => const AddNoteWidget(),
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (context) => const TransferClassWidget(),
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
