import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_profile/widgets/activity_section_widget.dart';
import 'package:teacher_app/features/child_profile/widgets/todays_meal_card_widget.dart';
import 'package:teacher_app/features/personal_information/widgets/day_strip_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ContentActivity extends StatelessWidget {
  const ContentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF).withValues(alpha: .4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -4),
            blurRadius: 16,
            color: Color(0xff000000).withValues(alpha: .1),
          ),
        ],
      ),
      child: Column(
        children: [
          DayStripWidget(),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Color(0xffFFFFFF).withValues(alpha: .8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff000000).withValues(alpha: .1),
                  offset: Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 36),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                ActivitySectionWidget(),
                SizedBox(height: 12),
                ActivitySectionWidget(),
                SizedBox(height: 12),
                ActivitySectionWidget(),
                SizedBox(height: 32),
                Text(
                  'Today’s Meal',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 16,
                    fontWeight: .w600,
                  ),
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    TodaysMealCardWidget(),
                    TodaysMealCardWidget(),
                    TodaysMealCardWidget(),
                  ],
                ),
                SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF7F7F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xffFAFAFA), width: 2),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      Assets.images.bottle.svg(),
                      SizedBox(width: 8),
                      Text(
                        'Bottle',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 16,
                          fontWeight: .w600,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '4 OZ',
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
          ),
        ],
      ),
    );
  }
}
