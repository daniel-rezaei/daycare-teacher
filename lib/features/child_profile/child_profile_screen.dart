import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_emergency_contact/presentation/bloc/child_emergency_contact_bloc.dart';
import 'package:teacher_app/features/child_profile/widgets/content_activity.dart';
import 'package:teacher_app/features/child_profile/widgets/content_overview.dart';
import 'package:teacher_app/features/child_profile/widgets/profile_section_widget.dart';
import 'package:teacher_app/features/child_profile/widgets/tabs_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';

class ChildProfileScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String? childPhoto;
  
  const ChildProfileScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.childPhoto,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  ValueNotifier<int> tabIndex = ValueNotifier(0);
  bool _hasRequestedData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (!_hasRequestedData && widget.childId.isNotEmpty) {
      _hasRequestedData = true;
      // دریافت همه بچه‌ها از /items/Child بدون فیلتر
      final currentState = context.read<ChildBloc>().state;
      if (currentState.children == null) {
        context.read<ChildBloc>().add(const GetAllChildrenEvent());
      }
      context.read<ChildBloc>().add(const GetAllContactsEvent());
      // دریافت emergency contacts (همه را می‌گیریم و بعد فیلتر می‌کنیم)
      context.read<ChildEmergencyContactBloc>().add(
            const GetAllChildEmergencyContactsEvent(),
          );
      // توجه: guardians و pickup authorization باید بعد از دریافت Child.id دریافت شوند
      // این کار در ContentOverview انجام می‌شود
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              children: [
                BackTitleWidget(
                  title: 'Child Profile',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ProfileChildSectionWidget(
                  childName: widget.childName,
                  childPhoto: widget.childPhoto,
                  childId: widget.childId,
                ),
                SizedBox(height: 20),
                SmoothTabs(
                  onChange: (index) {
                    tabIndex.value = index;
                  },
                ),
                SizedBox(height: 12),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: tabIndex,
                    builder: (context, value, child) {
                      return value == 0
                          ? SingleChildScrollView(
                              child: ContentOverview(childId: widget.childId),
                            )
                          : ContentActivity(childId: widget.childId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
