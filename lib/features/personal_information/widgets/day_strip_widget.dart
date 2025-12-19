import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class DayStripWidget extends StatefulWidget {
  final String? staffId;
  final Function(DateTime)? onDateSelected;

  const DayStripWidget({
    super.key,
    this.staffId,
    this.onDateSelected,
  });

  @override
  State<DayStripWidget> createState() => _DayStripWidgetState();
}

class _DayStripWidgetState extends State<DayStripWidget> {
  late DateTime selectedDate;
  late List<DateTime> dateList;
  final DateTime today = DateTime.now();
  final PageController controller = PageController(viewportFraction: 0.14);

  @override
  void initState() {
    super.initState();
    selectedDate = today;
    _generateDates(initial: true);
  }

  void _generateDates({bool initial = false}) {
    // تولید لیست تاریخ‌ها: از 30 روز قبل تا امروز
    final List<DateTime> allDates = [];
    for (int i = 30; i >= 0; i--) {
      allDates.add(today.subtract(Duration(days: i)));
    }

    int selectedIndex = allDates.indexWhere((d) => isSame(d, selectedDate));

    if (selectedIndex == -1) {
      selectedIndex = allDates.length - 1; // امروز
      selectedDate = allDates[selectedIndex];
    }

    if (initial) {
      int start = (selectedIndex - 5).clamp(0, allDates.length - 1);
      int end = (selectedIndex + 5).clamp(0, allDates.length - 1);
      dateList = allDates.sublist(start, end + 1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          controller.jumpToPage(selectedIndex - start);
        }
      });
    } else {
      dateList = allDates;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          controller.jumpToPage(selectedIndex);
        }
      });
    }
  }

  void _onPageChanged(int page) {
    DateTime newSelected = dateList[page];
    if (!isSame(newSelected, selectedDate)) {
      setState(() {
        selectedDate = newSelected;
        _generateDates();
      });
      widget.onDateSelected?.call(selectedDate);
    }
  }

  void goNext() {
    // فقط اگر روز بعدی قبل از امروز یا برابر با امروز باشد
    final nextDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day + 1,
    );
    if (!nextDate.isAfter(today)) {
      setState(() {
        selectedDate = nextDate;
        _generateDates();
      });
      widget.onDateSelected?.call(selectedDate);
    }
  }

  void goPrev() {
    final prevDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - 1,
    );
    setState(() {
      selectedDate = prevDate;
      _generateDates();
    });
    widget.onDateSelected?.call(selectedDate);
  }

  Color bgFor(DateTime date) {
    if (isSame(date, selectedDate)) return const Color(0xff9C5CFF);
    if (date.isBefore(selectedDate)) {
      return const Color(0xffF7F7F8).withValues(alpha: 0.56);
    }
    // روزهای آینده: رنگ متفاوت و غیرفعال
    return const Color(0xffFFFFFF).withValues(alpha: 0.86);
  }

  TextStyle styleFor(DateTime date) {
    if (isSame(date, selectedDate)) {
      return const TextStyle(
        color: Color(0xffFAFAFA),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      );
    }

    if (date.isBefore(selectedDate)) {
      return TextStyle(
        color: const Color(0xff71717A).withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      );
    }

    // روزهای آینده: رنگ کمرنگ‌تر
    return TextStyle(
      color: const Color(0xff6D6B76).withValues(alpha: 0.5),
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );
  }

  bool isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isFutureDate(DateTime date) {
    return date.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: goPrev,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Assets.images.altArrowLeft.svg(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _weekdayName(selectedDate),
                style: const TextStyle(
                  color: Color(0xff7B2AF3),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "${_monthName(selectedDate)} ${selectedDate.day}",
                style: const TextStyle(
                  color: Color(0xff444349),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              InkWell(
                onTap: _isFutureDate(
                  DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day + 1,
                  ),
                )
                    ? null
                    : goNext,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Opacity(
                    opacity: _isFutureDate(
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day + 1,
                      ),
                    )
                        ? 0.3
                        : 1.0,
                    child: Assets.images.altArrowRight.svg(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemCount: dateList.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              DateTime dt = dateList[index];
              final isFuture = _isFutureDate(dt);
              return Center(
                child: Container(
                  width: 46,
                  height: 64,
                  decoration: BoxDecoration(
                    color: bgFor(dt),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: InkWell(
                    onTap: isFuture
                        ? null
                        : () {
                            setState(() {
                              selectedDate = dt;
                              _generateDates();
                            });
                            widget.onDateSelected?.call(selectedDate);
                          },
                    child: Opacity(
                      opacity: isFuture ? 0.5 : 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${dt.day}", style: styleFor(dt)),
                          Text(_weekdayShort(dt), style: styleFor(dt)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _weekdayName(DateTime dt) {
    const names = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return names[dt.weekday - 1];
  }

  String _weekdayShort(DateTime dt) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[dt.weekday - 1];
  }

  String _monthName(DateTime dt) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[dt.month - 1];
  }
}
