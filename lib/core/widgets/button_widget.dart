import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final Function() onTap;
  const ButtonWidget({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xff9C5CFF),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: .center,
        child: Text(
          title,
          style: TextStyle(
            color: Color(0xffFAFAFA),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
