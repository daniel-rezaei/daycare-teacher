import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_status/widgets/add_note_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/transfer_class_widget.dart';

class MoreDetailsWidget extends StatelessWidget {
  const MoreDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, -4),
              color: Color(0xff95939D).withValues(alpha: .2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            HeaderCheckOut(isIcon: false, title: 'More Details'),
            Divider(color: Color(0xffDBDADD)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useSafeArea: true,
                    builder: (context) {
                      return AddNoteWidget();
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  color: Colors.transparent,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Note',
                    style: TextStyle(
                      color: Color(0xff444349),
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
                    builder: (context) {
                      return TransferClassWidget();
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  color: Colors.transparent,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Transfer Class',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
