import 'package:flutter/material.dart';
import 'package:teacher_app/features/activity/widgets/edit_record_widget.dart';
import 'package:teacher_app/features/activity/widgets/recording_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class RecordActivityScreen extends StatelessWidget {
  const RecordActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Assets.images.arrowLeft.svg(),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Record Activity – Toddler 2',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF).withValues(alpha: .6),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -4),
                          blurRadius: 16,
                          color: Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: ValueListenableBuilder(
                      valueListenable: RecordingWidget.isRecording,
                      builder: (context, isRecording, child) {
                        if (isRecording) {
                          return ListView.builder(
                            itemCount: 10,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffFFFFFF),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      color: Color(
                                        0xffBAB9C0,
                                      ).withValues(alpha: .32),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                margin: EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 32,
                                          width: 32,
                                          child: ClipOval(
                                            child: Assets
                                                .images
                                                .a71311088a9687505b49ce50537c803aa86b5242c
                                                .image(fit: .cover),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Sara Mali',
                                          style: TextStyle(
                                            color: Color(0xff444349),
                                            fontSize: 20,
                                            fontWeight: .w600,
                                          ),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              useSafeArea: true,
                                              builder: (context) {
                                                return EditRecordWidget();
                                              },
                                            );
                                          },
                                          child: Assets.images.edit.svg(),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Finished all of the PM snack',
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 14,
                                        fontWeight: .w400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: .center,
                            children: [
                              Assets.images.recordActivityPng.image(
                                height: 116,
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Record Activity',
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 30,
                                  fontWeight: .w600,
                                ),
                              ),
                              Text(
                                'Press the button below to record the activity.',
                                style: TextStyle(
                                  color: Color(
                                    0xff71717A,
                                  ).withValues(alpha: .8),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: RecordingWidget(),
    );
  }
}
