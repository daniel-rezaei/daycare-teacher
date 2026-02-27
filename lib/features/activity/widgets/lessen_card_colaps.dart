import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:teacher_app/core/palette.dart';

class LessonCardCollapseWidget extends StatefulWidget {
  final String date;
  final String title;
  final String category;
  final String ageBand;
  final String room;
  final VoidCallback? onArrowTap;

  const LessonCardCollapseWidget({
    super.key,
    required this.date,
    required this.category,
    required this.title,
    required this.ageBand,
    required this.room,
    this.onArrowTap,
  });

  @override
  State<LessonCardCollapseWidget> createState() => _LessonCardCollapseWidgetState();
}

class _LessonCardCollapseWidgetState extends State<LessonCardCollapseWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header (Clickable)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.bgBackground80,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Palette.textForeground,
                            ),
                          ),

                          SizedBox(height: 8),
                          Text(
                            widget.date,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Palette.textForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onArrowTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Palette.bgBackground90,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    label("Category", widget.category),
                    rowLabel(
                      "Age Band",
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          // optional future action
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_info.svg',
                                height: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.ageBand.isEmpty ? '-' : widget.ageBand,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Palette.txtPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    label("Room", widget.room),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget rowLabel(String text, Widget action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.grey)),
          action,
        ],
      ),
    );
  }

  Widget label(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
