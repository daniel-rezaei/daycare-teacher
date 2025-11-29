import 'package:flutter/material.dart';

class BottomNavigationBarChild extends StatelessWidget {
  const BottomNavigationBarChild({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Color(0xff9C5CFF),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: .center,
          child: Text(
            'Done',
            style: TextStyle(
              color: Color(0xffFAFAFA),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
