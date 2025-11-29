import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class RecordingWidget extends StatefulWidget {
  const RecordingWidget({super.key});

  @override
  State<RecordingWidget> createState() => _RecordingWidgetState();
  static ValueNotifier<bool> isRecording = ValueNotifier(false);
}

class _RecordingWidgetState extends State<RecordingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 212,
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF).withValues(alpha: .6),
        boxShadow: [BoxShadow(color: Color(0xff000000).withValues(alpha: .1))],
      ),

      padding: EdgeInsets.symmetric(horizontal: 32),
      child: ValueListenableBuilder(
        valueListenable: RecordingWidget.isRecording,
        builder: (context, isRecording, child) {
          return Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Assets.images.restart.svg(),
              ),
              isRecording
                  ? SizedBox(
                      width: 212, // فضای بزرگ‌تر برای موج‌ها
                      height: 212,
                      child: RippleAnimation(
                        child: GestureDetector(
                          onTap: () {
                            RecordingWidget.isRecording.value = false;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffFFFFFF),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Assets.images.secondary2.svg(),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        RecordingWidget.isRecording.value = true;
                      },
                      child: Assets.images.secondary.svg(),
                    ),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Assets.images.plain.svg(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RippleAnimation extends StatefulWidget {
  final Widget child;
  const RippleAnimation({super.key, required this.child});

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// موج اول - سفید کامل
        AnimatedBuilder(
          animation: _controller,
          builder: (_, _) {
            return Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: _opacity.value * 1),
                ),
              ),
            );
          },
        ),

        /// موج دوم - سفید کم‌رنگ‌تر
        AnimatedBuilder(
          animation: _controller,
          builder: (_, _) {
            return Transform.scale(
              scale: _scale.value * 1.2,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: _opacity.value * .4),
                ),
              ),
            );
          },
        ),

        widget.child,
      ],
    );
  }
}
