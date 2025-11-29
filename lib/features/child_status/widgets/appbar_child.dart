import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AppBarChild extends StatelessWidget {
  const AppBarChild({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Assets.images.arrowLeft.svg(),
            SizedBox(width: 16),
            Text(
              'Child Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff444349),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
