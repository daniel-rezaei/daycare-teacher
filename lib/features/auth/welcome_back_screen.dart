import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/auth/teacher_login_screen.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class WelcomeBackScreen extends StatelessWidget {
  const WelcomeBackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackTitleWidget(title: 'Sign In'),
            SizedBox(height: 40),
            Assets.images.logoSample.image(height: 116),
            SizedBox(height: 24),
            Text(
              'Welcome Back',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 30,
                fontWeight: .w600,
              ),
            ),
            Text(
              'Please sign in to continue',
              style: TextStyle(color: Color(0xff71717A).withValues(alpha: .8)),
            ),
            SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                color: Color(0xffF0E7FF),
                border: Border.all(width: 2, color: Color(0xffFAFAFA)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Assets.images.image.image(height: 48),
                  SizedBox(width: 8),
                  Text(
                    'Jane Doe',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontSize: 16,
                      fontWeight: .w600,
                    ),
                  ),
                  Spacer(),
                  Assets.images.checkbox.svg(),
                ],
              ),
            ),
            SizedBox(height: 16),
            PassTextField(),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: .center,
              children: [
                Assets.images.subtract3.svg(),
                SizedBox(width: 8),
                Text(
                  'Sign in with Face ID',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 16,
                    fontWeight: .w500,
                  ),
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
              child: ButtonWidget(
                title: 'Log In',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: .w500,
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class RememberMeWidget extends StatefulWidget {
  const RememberMeWidget({super.key});

  @override
  State<RememberMeWidget> createState() => _RememberMeWidgetState();
}

class _RememberMeWidgetState extends State<RememberMeWidget> {
  bool isRemember = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isRemember = !isRemember;
          });
        },
        child: Row(
          children: [
            isRemember
                ? Assets.images.checkbox.svg()
                : Assets.images.checkbox2.svg(),
            SizedBox(width: 12),
            Text(
              'Remember Me',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 14,
                fontWeight: .w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
