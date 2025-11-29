import 'package:flutter/material.dart';

class TabBottomNavigationBar extends StatelessWidget {
  final Widget icon;
  final Function()? onTap;
  final bool isActive;
  const TabBottomNavigationBar({
    super.key,
    required this.icon,
    this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: isActive
              ? BoxDecoration(color: Color(0xffF9F5FF), shape: BoxShape.circle)
              : null,
          child: icon,
        ),
      ),
    );
  }
}
