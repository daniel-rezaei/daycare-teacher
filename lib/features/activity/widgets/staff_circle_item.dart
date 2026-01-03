import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:teacher_app/core/pallete.dart';

class StaffCircleItem extends StatelessWidget {
  final String image;
  final String name;
  final String subTitle;
  final bool isSelected;

  const StaffCircleItem({
    super.key,
    required this.image,
    required this.name,
    required this.subTitle,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 130,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Border Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.white,
                    width: 1,
                  ),
                ),
              ),

              // Image
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Check Badge
              if (isSelected)
                Positioned(
                  bottom: 0,
                  right: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: SvgPicture.asset('assets/images/ic_radio_check.svg'),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            name,
            style: const TextStyle(
              color: Palette.textForeground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            subTitle,
            style: const TextStyle(
              color: Palette.textMutedForeground,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
