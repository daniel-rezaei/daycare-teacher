import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ItemWidget extends StatelessWidget {
  final Color colorIcon;
  final String title;
  final String dec;
  final Widget icon;
  const ItemWidget({
    super.key,
    required this.colorIcon,
    required this.title,
    required this.dec,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        border: Border.all(width: 2, color: Color(0xffFAFAFA)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Color(0xffE4D3FF).withValues(alpha: .5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorIcon,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(8),
            child: icon,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff681AD6),
                ),
              ),
              Text(
                dec,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff444349),
                ),
              ),
            ],
          ),
          Spacer(),
          SizedBox(
            height: 24,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              shrinkWrap: true,
              reverse: false,
              itemBuilder: (context, index) {
                return Transform.translate(
                  offset: Offset(-4.0 * index, 0),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Color(0xffFAFAFA)),
                      shape: .circle,
                    ),
                    child: index == 0 || index == 1
                        ? ClipOval(
                            child: Image.asset(
                              Assets
                                  .images
                                  .a6fadd07775295cc625abaf33feed2e172cf00a8c
                                  .path,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: Assets
                                .images
                                .a5332d31ac6cdbd6a5bfb62d59baefb6fb1383890
                                .image(),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
