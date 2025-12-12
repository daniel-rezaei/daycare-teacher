import 'package:flutter/material.dart';
import 'package:teacher_app/features/auth/presentation/logout_widget.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class SelectYourProfile extends StatelessWidget {
  const SelectYourProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackTitleWidget(title: 'Select Profile', onTap: () {}),
              SizedBox(height: 40),
              Text(
                'Select Your Profile',
                style: TextStyle(
                  color: Color(0xff444349),
                  fontSize: 30,
                  fontWeight: .w600,
                ),
              ),
              Text(
                'Choose your profile to continue',
                style: TextStyle(
                  color: Color(0xff71717A).withValues(alpha: .8),
                  fontSize: 16,
                  fontWeight: .w600,
                ),
              ),
              SizedBox(height: 24),
              Wrap(
                runSpacing: 16,
                spacing: 16,
                children: [
                  InfoCardSelectProfile(),
                  InfoCardSelectProfile(),
                  InfoCardSelectProfile(),
                  InfoCardSelectProfile(),
                  InfoCardSelectProfile(),
                  InfoCardSelectProfile(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 32,
                ),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      useSafeArea: true,
                      builder: (context) {
                        return LogoutWidget();
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Assets.images.logout.svg(),
                      SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 16,
                          fontWeight: .w600,
                        ),
                      ),
                      Spacer(),
                      Assets.images.arrowRight.svg(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCardSelectProfile extends StatelessWidget {
  const InfoCardSelectProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffF4F4F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: Color(0xffFAFAFA)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Assets.images.image.image(height: 100),
          SizedBox(height: 8),
          Text(
            'Katy Smith',
            style: TextStyle(
              color: Color(0xff444349),
              fontSize: 16,
              fontWeight: .w600,
            ),
          ),
          Text(
            'Supervisor',
            style: TextStyle(
              color: Color(0xff71717A),
              fontSize: 14,
              fontWeight: .w400,
            ),
          ),
        ],
      ),
    );
  }
}
