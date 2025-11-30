import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TeacherLoginScreen extends StatelessWidget {
  const TeacherLoginScreen({super.key});

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
              'Teacher Login',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 30,
                fontWeight: .w600,
              ),
            ),
            Text(
              'Sign in to manage your class',
              style: TextStyle(color: Color(0xff71717A).withValues(alpha: .8)),
            ),
            SizedBox(height: 48),
            MailTextField(),
            SizedBox(height: 16),
            PassTextField(),
            SizedBox(height: 32),
            RememberMeWidget(),
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

class MailTextField extends StatelessWidget {
  const MailTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Color(0xff000000).withValues(alpha: .05),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xffEFEEF0),
            hintText: 'Email',
            hintStyle: TextStyle(
              color: Color(0xff71717A).withValues(alpha: .8),
              fontSize: 14,
              fontWeight: .w400,
            ),
          ),
        ),
      ),
    );
  }
}

class PassTextField extends StatefulWidget {
  const PassTextField({super.key});

  @override
  State<PassTextField> createState() => _PassTextFieldState();
}

class _PassTextFieldState extends State<PassTextField> {
  bool isObscureText = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Color(0xff000000).withValues(alpha: .05),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: TextFormField(
          obscureText: isObscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xffEFEEF0),
            hintText: 'Password',
            hintStyle: TextStyle(
              color: Color(0xff71717A).withValues(alpha: .8),
              fontSize: 14,
              fontWeight: .w400,
            ),
            suffixIconConstraints: BoxConstraints(maxHeight: 20),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isObscureText = !isObscureText;
                  });
                },
                child: Assets.images.eyeClosed.svg(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
