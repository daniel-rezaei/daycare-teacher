import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ProfileChildSectionWidget extends StatelessWidget {
  const ProfileChildSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 16),
        Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.white),
            shape: .circle,
          ),
          child: ClipOval(
            child: Assets.images.a6fadd07775295cc625abaf33feed2e172cf00a8c
                .image(),
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'Sophia Johnson',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Color(0xffEFEEF0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 2, color: Color(0xffFAFAFA)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Color(0xffE4D3FF).withValues(alpha: .5),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Assets.images.gift.svg(),
                  SizedBox(width: 8),
                  Text(
                    'Date of Birth',
                    style: TextStyle(
                      color: Color(0xff444349),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Container(
                    width: 1,
                    height: 24,
                    decoration: BoxDecoration(color: Color(0xffDBDADD)),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'July 16 , 2025',
                    style: TextStyle(
                      color: Color(0xff7B2AF3),
                      fontSize: 14,
                      fontWeight: .w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
