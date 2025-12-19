import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/lifecycle_event_handler.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AddNoteWidget extends StatefulWidget {
  const AddNoteWidget({super.key});

  @override
  State<AddNoteWidget> createState() => _AddNoteWidgetState();
}

class _AddNoteWidgetState extends State<AddNoteWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // وقتی کیبورد باز/بسته شود، اسکرول اتوماتیک انجام می شود
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // لیسنر تغییر اندازه صفحه (کیبورد)
      WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(
          onMetricsChanged: () {
            Future.delayed(Duration(milliseconds: 150), () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetWrapper(
      child: Column(
        children: [
          const HeaderCheckOut(isIcon: false, title: 'Add Note'),
          const Divider(color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Assets.images.image.image(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Henry Davis',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const NoteWidget(title: 'Note', hintText: 'Placeholder'),
                const SizedBox(height: 20),
                AttachPhotoWidget(),
                const SizedBox(height: 32),
                ButtonWidget(
                  child: const Text(
                    'Save & Check In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
