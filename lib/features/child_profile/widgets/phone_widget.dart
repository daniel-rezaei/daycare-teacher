import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class PhoneWidget extends StatelessWidget {
  const PhoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Assets.images.phoneRounded2.svg(),
          SizedBox(width: 4),
          Text(
            '(123)234-1785',
            style: TextStyle(
              color: Color(0xff444349),
              fontSize: 12,
              fontWeight: .w500,
            ),
          ),
        ],
      ),
    );
  }
}
