import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/lifecycle_event_handler.dart';
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
          children: [
            HeaderCheckOut(isIcon: false, title: 'Add Note'),
            Divider(color: Color(0xffDBDADD)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(shape: .circle),
                        child: Assets.images.image.image(),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Henry Davis',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  NoteWidget(title: 'Note', hintText: 'Placeholder'),
                  SizedBox(height: 20),
                  AttachPhotoWidget(),
                  SizedBox(height: 32),
                  ButtonWidget(
                    child: Text(
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
      ),
    );
  }
}
