import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/auth/presentation/select_your_profile.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TimeInScreen extends StatelessWidget {
  const TimeInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackTitleWidget(title: 'Time In', onTap: () {}),
            SizedBox(height: 40),
            Assets.images.timeIn.svg(),
            SizedBox(height: 24),
            Text(
              'Staff Time- In Required',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 26,
                fontWeight: .w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'You must be on-site to Time-In',
              style: TextStyle(color: Color(0xff71717A).withValues(alpha: .8)),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
              child: ButtonWidget(
                child: Text(
                  'Time-In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectYourProfileScreen(
                        classId: '',
                        staffClasses: [],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              'Scan your QR code to Time-In',
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
