import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/lifecycle_event_handler.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';

class EditRecordWidget extends StatefulWidget {
  const EditRecordWidget({super.key});

  @override
  State<EditRecordWidget> createState() => _EditRecordWidgetState();
}

class _EditRecordWidgetState extends State<EditRecordWidget> {
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
      controller: _scrollController,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Color(0xff95939D).withValues(alpha: .2),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            HeaderCheckOut(isIcon: false, title: 'Edit Record'),
            Divider(color: Color(0xffDBDADD)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'You can edit the following text',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 20,
                      fontWeight: .w600,
                    ),
                  ),
                  SizedBox(height: 32),
                  NoteWidget(
                    title: 'Transcribed Text',
                    hintText:
                        'Sophia had half of the granola bar and half of the gapes for PM snack',
                  ),
                  SizedBox(height: 32),
                  ButtonWidget(
                    title: 'Save & Change',
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
