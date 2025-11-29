import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/lifecycle_event_handler.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class CheckOutWidget extends StatefulWidget {
  const CheckOutWidget({super.key});

  @override
  State<CheckOutWidget> createState() => _CheckOutWidgetState();
}

class _CheckOutWidgetState extends State<CheckOutWidget> {
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
            HeaderCheckOut(isIcon: true, title: 'Check Out'),
            Divider(color: Color(0xffDBDADD)),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Who is picking up Alice Johnson?',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 32),

                  ListView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Color(0xffF0E7FF),
                            border: Border.all(
                              color: Color(0xffFAFAFA),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffFAFAFA),
                                    width: 1,
                                  ),
                                  shape: BoxShape.circle,
                                ),

                                child: Assets.images.image.image(),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    'Jane Doe',
                                    style: TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Mother',
                                    style: TextStyle(
                                      color: Color(
                                        0xff71717A,
                                      ).withValues(alpha: .8),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Assets.images.checkbox.svg(),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          decoration: BoxDecoration(
                            color: Color(0xffF4F4F5),
                            border: Border.all(
                              color: Color(0xffFAFAFA),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Assets.images.image.image(),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    'Jane Doe',
                                    style: TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Mother',
                                    style: TextStyle(
                                      color: Color(
                                        0xff71717A,
                                      ).withValues(alpha: .8),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Assets.images.checkbox2.svg(),
                            ],
                          ),
                        );
                      }
                    },
                  ),

                  SizedBox(height: 16),
                  NoteWidget(title: 'Note', hintText: 'Placeholder'),
                  SizedBox(height: 20),
                  AttachPhotoWidget(),
                  SizedBox(height: 32),
                  ButtonWidget(
                    title: 'Submit',
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
