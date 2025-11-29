import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class CardNotificationsWidget extends StatelessWidget {
  const CardNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffDBDADD).withValues(alpha: .6),
        border: Border.all(width: 2, color: Color(0xffFAFAFA)),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Color(0xffE4D3FF).withValues(alpha: .5),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 0, 12),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Your class hasn’t started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff444349),
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'Class Check-In',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Assets.images.aIconNPng.image(),
        ],
      ),
    );
  }
}
