import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_profile/widgets/emergency_contacts.dart';
import 'package:teacher_app/features/child_profile/widgets/info_card_overview.dart';

class ContentOverview extends StatelessWidget {
  const ContentOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, -4),
            color: Color(0xff95939D).withValues(alpha: .2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 20, 16, 36),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [InfoCardOverview(), InfoCardOverview()],
          ),
          SizedBox(height: 12),
          EmergencyContacts(),
          SizedBox(height: 34),
          Text(
            'Authorized Pick-up',
            style: TextStyle(
              color: Color(0xff444349),
              fontSize: 16,
              fontWeight: .w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              PickUpWidget(),
              SizedBox(width: 12),
              PickUpWidget(),
              SizedBox(width: 12),
              PickUpWidget(),
            ],
          ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Color(0xffF4F4F5).withValues(alpha: .9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 2, color: Color(0xffFAFAFA)),
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Language Spoken',
                  style: TextStyle(
                    color: Color(0xff71717A).withValues(alpha: .8),
                    fontSize: 14,
                    fontWeight: .w400,
                  ),
                ),
                Text(
                  'English & Spanish',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 16,
                    fontWeight: .w600,
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

class PickUpWidget extends StatelessWidget {
  const PickUpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffF7F7F8),
          border: Border.all(width: 2, color: Color(0xffFAFAFA)),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'Jae',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: .w600,
              ),
            ),
            Text(
              'Mother',
              style: TextStyle(color: Color(0xff71717A).withValues(alpha: .8)),
            ),
          ],
        ),
      ),
    );
  }
}
