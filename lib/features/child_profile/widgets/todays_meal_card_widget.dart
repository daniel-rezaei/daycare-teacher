import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TodaysMealCardWidget extends StatelessWidget {
  const TodaysMealCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffF7F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xffFAFAFA), width: 2),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Assets.images.breakfast.svg(),
          SizedBox(height: 8),
          Text(
            'Apple',
            style: TextStyle(
              color: Color(0xff444349),
              fontSize: 16,
              fontWeight: .w600,
            ),
          ),
          Text(
            'Breakfast',
            style: TextStyle(
              color: Color(0xff71717A).withValues(alpha: .8),
              fontSize: 14,
              fontWeight: .w400,
            ),
          ),
        ],
      ),
    );
  }
}
