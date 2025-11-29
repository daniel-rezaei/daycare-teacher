import 'package:flutter/material.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class DayStripWidget extends StatefulWidget {
  const DayStripWidget({super.key});

  @override
  State<DayStripWidget> createState() => _DayStripWidgetState();
}

class _DayStripWidgetState extends State<DayStripWidget> {
  late DateTime selectedDate;
  late List<DateTime> dateList;

  final PageController controller = PageController(viewportFraction: 0.14);

  // لیست ثابت از تاریخ‌ها
  final List<DateTime> allDates = [
    DateTime(2025, 11, 20),
    DateTime(2025, 11, 21),
    DateTime(2025, 11, 22),
    DateTime(2025, 11, 23),
    DateTime(2025, 11, 24),
    DateTime(2025, 11, 25),
    DateTime(2025, 11, 26),
    DateTime(2025, 11, 27),
    DateTime(2025, 11, 28),
    DateTime(2025, 11, 29),
    DateTime(2025, 11, 30),
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _generateDates(initial: true);
  }

  void _generateDates({bool initial = false}) {
    int selectedIndex = allDates.indexWhere((d) => isSame(d, selectedDate));

    if (selectedIndex == -1) {
      // اگر تاریخ انتخابی در لیست نیست، از اولین تاریخ استفاده شود
      selectedIndex = 0;
      selectedDate = allDates[0];
    }

    if (initial) {
      // بار اول: 5 روز قبل و بعد (در صورت وجود)
      int start = (selectedIndex - 5).clamp(0, allDates.length - 1);
      int end = (selectedIndex + 5).clamp(0, allDates.length - 1);
      dateList = allDates.sublist(start, end + 1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.jumpToPage(selectedIndex - start);
      });
    } else {
      // بعد از آن: کل لیست ثابت باقی بماند
      dateList = allDates;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.jumpToPage(selectedIndex);
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
    }
  }

  void goNext() {
    int idx = allDates.indexWhere((d) => isSame(d, selectedDate));
    if (idx < allDates.length - 1) {
      setState(() {
        selectedDate = allDates[idx + 1];
        _generateDates();
      });
    }
  }

  void goPrev() {
    int idx = allDates.indexWhere((d) => isSame(d, selectedDate));
    if (idx > 0) {
      setState(() {
        selectedDate = allDates[idx - 1];
        _generateDates();
      });
    }
  }

  Color bgFor(DateTime date) {
    if (isSame(date, selectedDate)) return const Color(0xff9C5CFF);
    if (date.isBefore(selectedDate)) {
      return const Color(0xffF7F7F8).withValues(alpha: 0.56);
    }
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

    return const TextStyle(
      color: Color(0xff6D6B76),
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );
  }

  bool isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
                onTap: goNext,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Assets.images.altArrowRight.svg(),
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
              return Center(
                child: Container(
                  width: 46,
                  height: 64,
                  decoration: BoxDecoration(
                    color: bgFor(dt),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedDate = dt;
                        _generateDates();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${dt.day}", style: styleFor(dt)),
                        Text(_weekdayShort(dt), style: styleFor(dt)),
                      ],
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
