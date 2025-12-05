import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class LogActivityScreen extends StatelessWidget {
  const LogActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double cardWidth =
        (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;

    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Header ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Assets.images.arrowLeft.svg(),
                        const SizedBox(width: 16),
                        const Text(
                          'Log Activity – Toddler 2',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFFFF).withValues(alpha: .6),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withValues(alpha: .1),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),

                    /// ---------------- GRID + LAST ITEM FULL WIDTH ----------------
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.lunchPng.image(height: 48),
                              title: 'Meal',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.drink.image(height: 48),
                              title: 'Drink',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.learn.image(height: 48),
                              title: 'Learn',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.bathroom.image(height: 48),
                              title: 'Bathroom',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.play.image(height: 48),
                              title: 'Play',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.sleep.image(height: 48),
                              title: 'Sleep',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.observation.image(height: 48),
                              title: 'Observation',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.incident.image(height: 48),
                              title: 'Incident',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.accident.image(height: 48),
                              title: 'Accident',
                              onTap: () {},
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.attendance.image(height: 48),
                              title: 'Attendance',
                              onTap: () {},
                            ),
                          ),

                          /// ⭐⭐⭐ آیتم آخر – تمام عرض ⭐⭐⭐
                          SizedBox(
                            width: double.infinity,
                            child: InfoCardLogActivity(
                              icon: Assets.images.mood.image(height: 48),
                              title: 'Mood',
                              onTap: () {},
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
      ),
    );
  }
}

class InfoCardLogActivity extends StatelessWidget {
  final Widget icon;
  final String title;
  final Function() onTap;

  const InfoCardLogActivity({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          border: Border.all(color: const Color(0xffFAFAFA), width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffE4D3FF).withValues(alpha: .5),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
