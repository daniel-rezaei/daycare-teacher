import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/features/activity/widgets/lessen_card_colaps.dart';

class LessenList extends StatelessWidget {
  const LessenList({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];
    final dateFormat = DateFormat("MMM d, yyyy");
    final sampleDate = DateTime.parse("2025-07-16");
    final titles = [
      "Music & Movement",
      "Storytelling",
      "Nature Walk",
      "Sensory Exploration",
    ];
    for (var title in titles) {
      cards.add(
        LessenCardCollapse(
          title: title,
          date: dateFormat.format(sampleDate),
          category: "Art",
          ageBand: "Toddler 2",
          room: "Bluebird",
        ),
      );
      cards.add(const SizedBox(height: 12));
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: ListView(children: cards))],
        ),
      ),
    );
  }
}
