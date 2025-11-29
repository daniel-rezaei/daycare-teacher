import 'package:flutter/material.dart';
import 'package:teacher_app/features/activity/add_photo_screen.dart';
import 'package:teacher_app/features/activity/record_activity_screen.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 34,
                    ),
                    child: Text(
                      'Activity – Toddler 2',
                      style: TextStyle(
                        color: Color(0xff444349),
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        topLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -4),
                          blurRadius: 16,
                          color: Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                    child: Column(
                      children: [
                        Stack(
                          alignment: .center,
                          children: [
                            Assets.images.dateIconPng.image(height: 198),
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.08,
                              child: Column(
                                children: [
                                  Text(
                                    'Sun',
                                    style: TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 20,
                                      fontWeight: .w600,
                                    ),
                                  ),
                                  Text(
                                    '8',
                                    style: TextStyle(
                                      color: Color(0xff7B2AF3),
                                      fontSize: 60,
                                      fontWeight: .w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 48),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecordActivityScreen(),
                              ),
                            );
                          },
                          child: Assets.images.infoCardPng.image(),
                        ),
                        SizedBox(height: 8),
                        Assets.images.infoCard2.image(),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddPhotoScreen(),
                              ),
                            );
                          },
                          child: Assets.images.infoCard3.image(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
