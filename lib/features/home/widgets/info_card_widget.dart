import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final Color color;
  final Widget icon;
  final String title;
  final String dec;
  final Function() onTap;
  const InfoCardWidget({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.dec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(width: 2, color: Color(0XFFFAFAFA)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Color(0XFFE4D3FF).withValues(alpha: .5),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 30),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffEFFAFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: icon,
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff444349),
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
            ],
          ),
        ),
      ),
    );
  }
}
