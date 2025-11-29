import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(
            'Home',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff444349),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Color(0xffFFFFFF).withValues(alpha: .4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 2, color: Color(0xffFAFAFA)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Color(0xffE4D3FF).withValues(alpha: .5),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Assets.images.leftSlotItems.svg(),
                SizedBox(width: 8),
                Text(
                  'Toddler 2',
                  style: TextStyle(
                    color: Color(0xff681AD6),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
