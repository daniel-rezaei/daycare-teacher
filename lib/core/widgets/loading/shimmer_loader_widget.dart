import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

/// Shimmer loader widget for skeleton loading states
class ShimmerLoaderWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoaderWidget({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
