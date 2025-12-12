import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/auth/presentation/teacher_login_screen.dart';
import 'package:teacher_app/features/child_status/widgets/transfer_class_widget.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class SelectClassScreen extends StatefulWidget {
  const SelectClassScreen({super.key});

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  String? selectedClass;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackTitleWidget(
              title: 'Toddler 2 Class',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 40),
            Assets.images.logoSample.image(height: 116),
            SizedBox(height: 24),
            Text(
              'Select Your Class',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 30,
                fontWeight: .w600,
              ),
            ),
            Text(
              'Choose the class you want to access',
              style: TextStyle(color: Color(0xff71717A).withValues(alpha: .8)),
            ),
            SizedBox(height: 48),
            TransferClassList(
              selectedClass: selectedClass,
              onClassSelected: (value) {
                setState(() {
                  selectedClass = value;
                });
              },
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: ButtonWidget(
                title: 'Continue',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherLoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
