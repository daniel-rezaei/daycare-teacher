import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_profile/widgets/phone_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class EmergencyContacts extends StatelessWidget {
  const EmergencyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: EdgeInsets.zero,
          collapsedBackgroundColor: Color(0xffEFEEF0),
          backgroundColor: Color(0xffEFEEF0),
          iconColor: Color(0xff444349),
          collapsedIconColor: Color(0xff444349),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          // ---------------- HEADER ----------------
          title: Container(
            decoration: BoxDecoration(
              color: Color(0xffEFEEF0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Assets.images.emergencyContacts.svg(),
                ),
                SizedBox(width: 12),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ---------------- EXPANDED CONTENT ----------------
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xffF7F7F8),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xffFEE5F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(width: 2, color: Color(0xffFAFAFA)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffE4D3FF).withValues(alpha: .5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jessamine Mumtaz',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        PhoneWidget(),
                      ],
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
