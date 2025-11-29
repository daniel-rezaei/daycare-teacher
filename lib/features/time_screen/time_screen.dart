import 'dart:async';

import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TimeScreen extends StatelessWidget {
  const TimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundWidget(),
        SafeArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 34,
                ),
                child: Text(
                  'Time',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xffFFFFFF),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, -4),
                        blurRadius: 16,
                        color: Color(0xff000000).withValues(alpha: .1),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(40),
                  child: ValueListenableBuilder(
                    valueListenable: TimeTracker.isRunning,
                    builder: (context, running, child) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 96),
                            child: running
                                ? Assets.images.timeout.svg()
                                : Assets.images.timeIn.svg(),
                          ),
                          SizedBox(height: 24),
                          Text(
                            running ? 'Time_Out' : 'Please Time_In First',
                            style: TextStyle(
                              color: Color(0xff444349),
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            running
                                ? 'Are you sure you want to Time Out?'
                                : 'To access your account, make sure you’ve timed in with your daycare',
                            style: TextStyle(
                              color: Color(0xff71717A).withValues(alpha: .8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),

                          // نمایش تایمر
                          ValueListenableBuilder(
                            valueListenable: TimeTracker.isRunning,
                            builder: (context, running, child) {
                              if (running) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffF4F4F5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: ValueListenableBuilder<Duration>(
                                    valueListenable: TimeTracker.elapsed,
                                    builder: (context, value, _) {
                                      return Text(
                                        TimeTracker.format(value),
                                        style: TextStyle(
                                          color: Color(0xff444349),
                                          fontSize: 36,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),

                          Spacer(),

                          // دکمه Time-In / Time-Out
                          ValueListenableBuilder<bool>(
                            valueListenable: TimeTracker.isRunning,
                            builder: (context, running, _) {
                              return ButtonWidget(
                                title: running ? 'Time-Out' : 'Time-In',
                                onTap: () {
                                  TimeTracker.toggle();
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TimeTracker {
  static ValueNotifier<Duration> elapsed = ValueNotifier(Duration.zero);
  static ValueNotifier<bool> isRunning = ValueNotifier(false);

  static DateTime? _start;
  static Timer? _timer;
  static DateTime? _lastResetDate;

  /// شروع یا ادامه تایمر
  static void toggle() {
    final now = DateTime.now();

    // ریست کردن اگر روز جدید آمده
    if (_lastResetDate == null ||
        now.day != _lastResetDate!.day ||
        now.difference(_lastResetDate!).inHours >= 24) {
      reset();
    }

    if (_timer == null) {
      // شروع تایمر
      _start = now.subtract(elapsed.value);
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        elapsed.value = DateTime.now().difference(_start!);
      });
      isRunning.value = true;
    } else {
      // متوقف کردن تایمر
      _timer?.cancel();
      _timer = null;
      isRunning.value = false;
    }
  }

  /// ریست تایمر به صفر
  static void reset() {
    _timer?.cancel();
    _timer = null;
    elapsed.value = Duration.zero;
    isRunning.value = false;
    _lastResetDate = DateTime.now();
  }

  static String format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}
