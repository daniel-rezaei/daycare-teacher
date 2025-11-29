import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class UpcomingEventsCardStackUI extends StatefulWidget {
  final List<EventUiModel> events;

  const UpcomingEventsCardStackUI({super.key, required this.events});

  @override
  State<UpcomingEventsCardStackUI> createState() =>
      _UpcomingEventsCardStackUIState();
}

class _UpcomingEventsCardStackUIState extends State<UpcomingEventsCardStackUI> {
  int selectedIndex = 0;

  final double smallCardWidth = 40.0;
  final double cardHeight = 95.0;
  final double smallCardOverlap = 12.0;

  String formatShortDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('d MMM').format(date);
  }

  List<String> formatDateParts(DateTime date) {
    final weekday = DateFormat('EEEE').format(date);
    final monthDay = DateFormat('MMMM d').format(date);
    final time = DateFormat('hh:mm a').format(date);
    return [weekday, monthDay, time];
  }

  @override
  Widget build(BuildContext context) {
    final displayedEvents = widget.events.take(3).toList();

    if (displayedEvents.isEmpty) return const SizedBox.shrink();
    if (selectedIndex >= displayedEvents.length) selectedIndex = 0;

    final selectedEvent = displayedEvents[selectedIndex];
    final dateParts = formatDateParts(selectedEvent.date ?? DateTime.now());

    final totalSmallCardsWidth =
        displayedEvents.length * (smallCardWidth - smallCardOverlap);

    final bigCardWidth =
        MediaQuery.of(context).size.width - totalSmallCardsWidth - 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...List.generate(displayedEvents.length, (index) {
                final event = displayedEvents[index];
                final isSelected = index == selectedIndex;

                return Positioned(
                  left: index * (smallCardWidth - smallCardOverlap),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: smallCardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEEF0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          formatShortDate(event.date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              Positioned(
                left: totalSmallCardsWidth,
                right: 1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.2, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Container(
                    key: ValueKey(selectedEvent.id),
                    height: cardHeight,
                    width: bigCardWidth,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffFAFAFA), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          child: Assets.images.backgroundUpcoming.image(
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedEvent.title ?? "-",
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Assets.images.calendarDate.svg(),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          dateParts.length,
                                          (i) {
                                            return Row(
                                              children: [
                                                Text(
                                                  dateParts[i],
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                if (i != dateParts.length - 1)
                                                  Container(
                                                    width: 1,
                                                    height: 16,
                                                    color: Colors.grey[400],
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                        ),
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
                          ),
                        ),
                      ],
                    ),
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

class EventUiModel {
  final int id;
  final String? title;
  final DateTime? date;

  EventUiModel({required this.id, this.title, this.date});
}
