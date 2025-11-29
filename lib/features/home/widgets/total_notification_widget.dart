import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_status/child_status.dart';
import 'package:teacher_app/features/home/widgets/info_card_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TotalNotificationWidget extends StatelessWidget {
  const TotalNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        InfoCardWidget(
          color: Color(0XFFDEF4FF),
          icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Assets.images.subtract.svg(),
          ),
          title: '3/10',
          dec: 'Total Children',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChildStatus()),
            );
          },
        ),
        SizedBox(width: 8),
        InfoCardWidget(
          color: Color(0xffFEE5F2),
          icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Assets.images.vector.svg(),
          ),
          title: '5',
          dec: 'Notifications',
          onTap: () {},
        ),
      ],
    );
  }
}
