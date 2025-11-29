import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/upcoming_event_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class UpcomingEventsHeaderWidget extends StatelessWidget {
  const UpcomingEventsHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: .center,
          children: [
            Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff444349),
              ),
            ),
            Spacer(),
            Text(
              'More',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff444349),
              ),
            ),
            SizedBox(width: 4),
            Assets.images.next.svg(),
          ],
        ),
        SizedBox(height: 14),
        UpcomingEventsCardStackUI(
          events: [
            EventUiModel(
              id: 1,
              title: "Sports Day",
              date: DateTime.now().add(Duration(days: 1)),
            ),
            EventUiModel(
              id: 2,
              title: "Workshop",
              date: DateTime.now().add(Duration(days: 3)),
            ),
          ],
        ),
      ],
    );
  }
}
