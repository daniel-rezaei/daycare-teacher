import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isEnabled;
  final Widget child;

  const ButtonWidget({
    super.key,
    required this.onTap,
    required this.child,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1 : 0.5,
        child: Container(
          height: 52,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xff6C4EFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}
