import 'package:flutter/material.dart';

class SmoothTabs extends StatefulWidget {
  final ValueChanged<int>? onChange; // اضافه شد

  const SmoothTabs({super.key, this.onChange});

  @override
  State<SmoothTabs> createState() => _SmoothTabsState();
}

class _SmoothTabsState extends State<SmoothTabs> {
  int current = 0;

  void _setTab(int index) {
    setState(() => current = index);

    /// ارسال به بیرون
    if (widget.onChange != null) {
      widget.onChange!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF).withValues(alpha: .74),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;

          return Stack(
            children: [
              /// Indicator animation
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                left: current * tabWidth,
                child: Container(
                  width: tabWidth,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffBAB9C0).withValues(alpha: .5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              /// Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _setTab(0),
                      child: Center(
                        child: Text(
                          "Overview",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: current == 0
                                ? const Color(0xff7B2AF3)
                                : const Color(0xff71717A).withValues(alpha: .8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _setTab(1),
                      child: Center(
                        child: Text(
                          "Activity",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: current == 1
                                ? const Color(0xff7B2AF3)
                                : const Color(0xff71717A).withValues(alpha: .8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
