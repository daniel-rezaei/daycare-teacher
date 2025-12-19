import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_emergency_contact/presentation/bloc/child_emergency_contact_bloc.dart';
import 'package:teacher_app/features/child_guardian/presentation/bloc/child_guardian_bloc.dart';
import 'package:teacher_app/features/child_profile/widgets/content_activity.dart';
import 'package:teacher_app/features/child_profile/widgets/content_overview.dart';
import 'package:teacher_app/features/child_profile/widgets/profile_section_widget.dart';
import 'package:teacher_app/features/child_profile/widgets/tabs_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/features/pickup_authorization/presentation/bloc/pickup_authorization_bloc.dart';

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
      // استفاده از contactId برای دریافت Child
      context.read<ChildBloc>().add(GetChildByContactIdEvent(contactId: widget.childId));
      context.read<ChildBloc>().add(const GetAllContactsEvent());
      // child_id در جداول دیگر به contactId اشاره می‌کند
      context.read<ChildGuardianBloc>().add(
            GetChildGuardianByChildIdEvent(childId: widget.childId),
          );
      context.read<ChildEmergencyContactBloc>().add(
            const GetAllChildEmergencyContactsEvent(),
          );
      context.read<PickupAuthorizationBloc>().add(
            GetPickupAuthorizationByChildIdEvent(childId: widget.childId),
          );
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
                  child: SingleChildScrollView(
                    child: ValueListenableBuilder(
                      valueListenable: tabIndex,
                      builder: (context, value, child) {
                        if (value == 0) {
                          return ContentOverview(childId: widget.childId);
                        } else {
                          return ContentActivity();
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
    );
  }
}
