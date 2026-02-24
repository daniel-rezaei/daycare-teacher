import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

/// صفحهٔ لودینگ یکپارچه و برندشده برای اسپلش اول اپ و بعد از لاگین.
/// تجربهٔ کاربری یکسان و حرفه‌ای بدون صفحه سیاه یا متن‌های تکنیکال.
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    super.key,
    this.message,
  });

  /// متن اختیاری زیر اندیکاتور (مثلاً «در حال آماده‌سازی...»). برای اسپلش خالی بگذارید.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F0FF),
              Color(0xFFE8F4F8),
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // لوگو
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  Assets.images.logoSample.path,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildFallbackLogo(context),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Daycare',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff9C5CFF),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(flex: 2),
              // اندیکاتور لودینگ ظریف
              _LoadingIndicator(),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xff9C5CFF).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.child_care_rounded,
        size: 48,
        color: Color(0xff9C5CFF),
      ),
    );
  }
}

/// اندیکاتور دایره‌ای نازک با انیمیشن
class _LoadingIndicator extends StatefulWidget {
  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircleLoadingPainter(
              progress: _controller.value,
              color: const Color(0xff9C5CFF),
            ),
          );
        },
      ),
    );
  }
}

class _CircleLoadingPainter extends CustomPainter {
  _CircleLoadingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth;

    // پس‌زمینه دایره کم‌رنگ
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // قوس در حال چرخش
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    const sweepAngle = math.pi * 1.5;
    final start = startAngle + progress * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
