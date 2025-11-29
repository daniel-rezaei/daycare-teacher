import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_profile/widgets/content_activity.dart';
import 'package:teacher_app/features/child_profile/widgets/content_overview.dart';
import 'package:teacher_app/features/child_profile/widgets/profile_section_widget.dart';
import 'package:teacher_app/features/child_profile/widgets/tabs_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  ValueNotifier<int> tabIndex = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BackTitleWidget(title: 'Child Profile'),
                  ProfileChildSectionWidget(),
                  SizedBox(height: 20),
                  SmoothTabs(
                    onChange: (index) {
                      tabIndex.value = index;
                    },
                  ),
                  SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: tabIndex,
                    builder: (context, value, child) {
                      if (value == 0) {
                        return ContentOverview();
                      } else {
                        return ContentActivity();
                      }
                    },
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
