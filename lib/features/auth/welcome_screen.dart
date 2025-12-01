import 'package:flutter/material.dart';
import 'package:teacher_app/features/auth/select_class_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: .expand,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 290),
              child: Assets.images.illustration.image(),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        color: Color(0xff6D6B76),
                        fontSize: 30,
                        fontWeight: .w600,
                      ),
                    ),
                    Text(
                      'Daycare',
                      style: TextStyle(
                        color: Color(0xff9C5CFF),
                        fontSize: 30,
                        fontWeight: .w600,
                      ),
                    ),
                    SizedBox(height: 24),
                    InfoCardWelcome(
                      icon: Assets.images.sharedMode.svg(),
                      title: 'Shared Mode',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectClassScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    InfoCardWelcome(
                      icon: Assets.images.individualMode.svg(),
                      title: 'Individual Mode',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCardWelcome extends StatelessWidget {
  final Widget icon;
  final String title;
  final Function() onTap;
  const InfoCardWelcome({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 2, color: Color(0xffFAFAFA)),
          boxShadow: [
            BoxShadow(
              color: Color(0xffE4D3FF).withValues(alpha: .5),
              blurRadius: 8,
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            icon,
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: .w600,
              ),
            ),
            Spacer(),
            Assets.images.iconButton2.svg(),
          ],
        ),
      ),
    );
  }
}
