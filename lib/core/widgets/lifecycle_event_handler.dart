// کلاس کمکی برای گوش دادن به تغییرات کیبورد
import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Function onMetricsChanged;

  LifecycleEventHandler({required this.onMetricsChanged});

  @override
  void didChangeMetrics() {
    onMetricsChanged();
  }
}
