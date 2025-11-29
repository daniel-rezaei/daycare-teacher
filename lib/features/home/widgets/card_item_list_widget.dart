import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/item_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class CardItemListWidget extends StatelessWidget {
  const CardItemListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ItemWidget(
          colorIcon: Color(0xffF9F5FF),
          title: 'Birthday',
          dec: 'John’s, Sofia & Lia Birthday',
          icon: Assets.images.birthday.svg(),
        ),
        SizedBox(height: 12),
        ItemWidget(
          colorIcon: Color(0xffFEF1F8),
          title: 'Dietary Restriction',
          dec: 'Sara allergy to',
          icon: Assets.images.dietaryRestrictions.svg(),
        ),
        SizedBox(height: 12),
        ItemWidget(
          colorIcon: Color(0xffEFFEF5),
          title: 'Medicine',
          dec: 'Joe Aspirin tablet at',
          icon: Assets.images.medication.svg(),
        ),
      ],
    );
  }
}
