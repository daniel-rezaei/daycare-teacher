import 'package:flutter/material.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/presentation/logout_widget.dart';
import 'package:teacher_app/features/auth/presentation/welcome_back_screen.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class SelectYourProfileScreen extends StatelessWidget {
  final String classId;
  final List<StaffClassEntity> staffClasses;

  const SelectYourProfileScreen({
    super.key,
    required this.classId,
    required this.staffClasses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _LogoutSection(), // 👈 همیشه پایین

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24), // فاصله از لاگ‌اوت
          child: Column(
            children: [
              /// 🔹 Header
              BackTitleWidget(
                title: 'Select Profile',
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 40),

              /// 🔹 Titles
              const Text(
                'Select Your Profile',
                style: TextStyle(
                  color: Color(0xff444349),
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Choose your profile to continue',
                style: TextStyle(
                  color: const Color(0xff71717A).withValues(alpha: .8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              /// 🔹 Profiles
              _ProfilesGrid(
                staffClasses: staffClasses,
                onProfileTap: (staff) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WelcomeBackScreen(
                        staff: staff,
                        classId: classId,
                        staffClasses: staffClasses,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 16, 40, 32),
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              useSafeArea: true,
              builder: (_) => const LogoutWidget(),
            );
          },
          child: Row(
            children: [
              Assets.images.logout.svg(),
              const SizedBox(width: 8),
              const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xff444349),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Assets.images.arrowRight.svg(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilesGrid extends StatelessWidget {
  final List<StaffClassEntity> staffClasses;
  final ValueChanged<StaffClassEntity> onProfileTap;

  const _ProfilesGrid({required this.staffClasses, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    if (staffClasses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No staff found for this class',
          style: TextStyle(color: Color(0xff71717A), fontSize: 14),
        ),
      );
    }

    return Wrap(
      runSpacing: 16,
      spacing: 16,
      children: staffClasses.map((staff) {
        return GestureDetector(
          onTap: () => onProfileTap(staff),
          child: InfoCardSelectProfile(staff: staff),
        );
      }).toList(),
    );
  }
}

class InfoCardSelectProfile extends StatelessWidget {
  final StaffClassEntity staff;
  const InfoCardSelectProfile({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: const Color(0xffFAFAFA)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Assets.images.image.image(height: 100),
          const SizedBox(height: 8),
          Text(
            '${staff.firstName} ${staff.lastName}',
            style: TextStyle(
              color: Color(0xff444349),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            staff.role,
            style: TextStyle(
              color: Color(0xff71717A),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
