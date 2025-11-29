import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class HeaderCheckOut extends StatelessWidget {
  final bool isIcon;
  final String title;
  const HeaderCheckOut({super.key, required this.isIcon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Row(
        children: [
          isIcon ? Assets.images.subtract2.svg() : SizedBox.shrink(),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Color(0xff6D6B76),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Assets.images.iconButton.svg(),
          ),
        ],
      ),
    );
  }
}
