import 'package:flutter/material.dart';
import 'package:teacher_app/features/activity/activity_screen.dart';
import 'package:teacher_app/features/home/widgets/appbar_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/widgets/bottom_navigation_bar_widget.dart';
import 'package:teacher_app/features/home/widgets/card_widget.dart';
import 'package:teacher_app/features/home/widgets/profile_section_widget.dart';
import 'package:teacher_app/features/messages/messages_screen.dart';
import 'package:teacher_app/features/time_screen/time_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  static ValueNotifier<int> pageIndex = ValueNotifier(0);
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: MyHomePage.pageIndex,
        builder: (context, value, child) {
          if (value == 0) {
            return Stack(
              children: [
                BackgroundWidget(),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AppbarWidget(),
                        ProfileSectionWidget(),
                        CardWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (value == 1) {
            return TimeScreen();
          } else if (value == 2) {
            return ActivityScreen();
          } else if (value == 3) {
            return MessagesScreen();
          } else {
            return Container();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
