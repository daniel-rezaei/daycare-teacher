import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/my_home_page.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class LogoutWidget extends StatefulWidget {
  const LogoutWidget({super.key});

  @override
  State<LogoutWidget> createState() => _LogoutWidgetState();
}

class _LogoutWidgetState extends State<LogoutWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, -4),
              color: Color(0xff95939D).withValues(alpha: .2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Row(
                children: [
                  Assets.images.logout.svg(),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xff6D6B76),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Assets.images.iconButton.svg(),
                  ),
                ],
              ),
            ),
            Divider(color: Color(0xffDBDADD)),
            SizedBox(height: 20),
            Assets.images.exitDuotone.svg(),
            SizedBox(height: 24),
            Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 24,
                fontWeight: .w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Sign out of your account and return to the login screen.',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 12,
                fontWeight: .w400,
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xff9C5CFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: .center,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Color(0xffFAFAFA),
                    fontSize: 16,
                    fontWeight: .w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xffDBDADD)),
                ),
                alignment: .center,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xff6D6B76),
                    fontSize: 16,
                    fontWeight: .w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
