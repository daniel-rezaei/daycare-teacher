import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_profile/widgets/phone_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class InfoCardOverview extends StatelessWidget {
  const InfoCardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffF0E7FF),
          border: Border.all(color: Color(0xffFAFAFA), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: Assets.images.image.image(),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Jane Doe',
                      style: TextStyle(
                        color: Color(0xff444349),
                        fontSize: 16,
                        fontWeight: .w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mother',
                      style: TextStyle(
                        color: Color(0xff71717A).withValues(alpha: .8),
                        fontSize: 14,
                        fontWeight: .w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            PhoneWidget(),
          ],
        ),
      ),
    );
  }
}
