import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ActivitySectionWidget extends StatelessWidget {
  const ActivitySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xffBAB9C0).withValues(alpha: .32),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: .center,
            children: [
              Text(
                '08:00',
                style: TextStyle(
                  color: Color(0xff444349),
                  fontSize: 16,
                  fontWeight: .w600,
                ),
              ),
              Text(
                'AM',
                style: TextStyle(
                  color: Color(0xff6D6B76),
                  fontSize: 14,
                  fontWeight: .w400,
                ),
              ),
            ],
          ),
          SizedBox(width: 22),
          Container(
            height: 112,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Color(0xffDBDADD)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffEFFAFF),
                          shape: .circle,
                        ),
                        padding: EdgeInsets.all(6),
                        child: Assets.images.subtract.svg(),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Check_In',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 16,
                          fontWeight: .w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xffF7F7F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(
                          'Brought By',
                          style: TextStyle(
                            color: Color(0xff6D6B76),
                            fontSize: 14,
                            fontWeight: .w600,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: Assets.images.image.image(),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Julie Brown',
                              style: TextStyle(
                                color: Color(0xff444349),
                                fontSize: 14,
                                fontWeight: .w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
