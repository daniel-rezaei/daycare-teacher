import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// ویجت اسکلتون یکپارچه برای جایگزینی لودینگ‌های صفحه.
/// کاربر به‌جای اسپینر، شکل نهایی محتوا را با انیمیشن ملایم می‌بیند.
class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// دایرهٔ شیمر (مثلاً برای آواتار)
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
