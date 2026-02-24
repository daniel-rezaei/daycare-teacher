import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teacher_app/features/activity/widgets/lessen_card_colaps.dart';

class LessenListWidget extends StatelessWidget {
  const LessenListWidget({super.key, this.searchQuery = ''});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];
    final dateFormat = DateFormat("MMM d, yyyy");
    final sampleDate = DateTime.parse("2025-07-16");
    const titles = [
      "Music & Movement",
      "Storytelling",
      "Nature Walk",
      "Sensory Exploration",
    ];
    final query = searchQuery.toLowerCase();
    final filteredTitles = query.isEmpty
        ? titles
        : titles.where((t) => t.toLowerCase().contains(query)).toList();

    for (var title in filteredTitles) {
      cards.add(
        LessonCardCollapseWidget(
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
          children: [
            Expanded(
              child: filteredTitles.isEmpty
                  ? Center(
                      child: Text(
                        'No lessens match "$searchQuery"',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView(children: cards),
            ),
          ],
        ),
      ),
    );
  }
}
