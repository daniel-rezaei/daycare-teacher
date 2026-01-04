import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/messages/select_childs_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  String? _classId;

  @override
  void initState() {
    super.initState();
    _loadClassId();
  }

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString(AppConstants.classIdKey);
    debugPrint('[LOG_ACTIVITY] Loading class_id: $savedClassId');
    
    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        _classId = savedClassId;
      });
    }
  }

  void _navigateToMealActivity(BuildContext context) async {
    debugPrint('[LOG_ACTIVITY] Navigating to SelectChildsScreen for Meal Activity');
    debugPrint('[LOG_ACTIVITY] class_id: $_classId');
    debugPrint('[LOG_ACTIVITY] NOTE: BottomSheet will be opened from BOTTOM ACTION ICON, not from back button');
    
    // Navigate to SelectChildsScreen
    // The BottomSheet will be opened by the BOTTOM ACTION ICON in SelectChildsScreen
    // Back button will just navigate back without opening BottomSheet
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: _classId,
          activityType: 'meal',
        ),
      ),
    );

    debugPrint('[LOG_ACTIVITY] Returning from SelectChildsScreen');
    debugPrint('[LOG_ACTIVITY] BottomSheet was opened from BOTTOM ACTION ICON (if user selected children)');
    debugPrint('[LOG_ACTIVITY] Back button does NOT trigger BottomSheet');
  }

  void _navigateToDrinkActivity(BuildContext context) async {
    debugPrint('[LOG_ACTIVITY] Navigating to SelectChildsScreen for Drink Activity');
    debugPrint('[LOG_ACTIVITY] class_id: $_classId');
    debugPrint('[LOG_ACTIVITY] NOTE: BottomSheet will be opened from BOTTOM ACTION ICON, not from back button');
    
    // Navigate to SelectChildsScreen
    // The BottomSheet will be opened by the BOTTOM ACTION ICON in SelectChildsScreen
    // Back button will just navigate back without opening BottomSheet
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: _classId,
          activityType: 'drink',
        ),
      ),
    );

    debugPrint('[LOG_ACTIVITY] Returning from SelectChildsScreen');
    debugPrint('[LOG_ACTIVITY] BottomSheet was opened from BOTTOM ACTION ICON (if user selected children)');
    debugPrint('[LOG_ACTIVITY] Back button does NOT trigger BottomSheet');
  }

  void _navigateToBathroomActivity(BuildContext context) async {
    debugPrint('[LOG_ACTIVITY] Navigating to SelectChildsScreen for Bathroom Activity');
    debugPrint('[LOG_ACTIVITY] class_id: $_classId');
    debugPrint('[LOG_ACTIVITY] NOTE: BottomSheet will be opened from BOTTOM ACTION ICON, not from back button');
    
    // Navigate to SelectChildsScreen
    // The BottomSheet will be opened by the BOTTOM ACTION ICON in SelectChildsScreen
    // Back button will just navigate back without opening BottomSheet
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: _classId,
          activityType: 'bathroom',
        ),
      ),
    );

    debugPrint('[LOG_ACTIVITY] Returning from SelectChildsScreen');
    debugPrint('[LOG_ACTIVITY] BottomSheet was opened from BOTTOM ACTION ICON (if user selected children)');
    debugPrint('[LOG_ACTIVITY] Back button does NOT trigger BottomSheet');
  }

  void _navigateToPlayActivity(BuildContext context) async {
    debugPrint('[LOG_ACTIVITY] Navigating to SelectChildsScreen for Play Activity');
    debugPrint('[LOG_ACTIVITY] class_id: $_classId');
    debugPrint('[LOG_ACTIVITY] NOTE: BottomSheet will be opened from BOTTOM ACTION ICON, not from back button');
    
    // Navigate to SelectChildsScreen
    // The BottomSheet will be opened by the BOTTOM ACTION ICON in SelectChildsScreen
    // Back button will just navigate back without opening BottomSheet
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: _classId,
          activityType: 'play',
        ),
      ),
    );

    debugPrint('[LOG_ACTIVITY] Returning from SelectChildsScreen');
    debugPrint('[LOG_ACTIVITY] BottomSheet was opened from BOTTOM ACTION ICON (if user selected children)');
    debugPrint('[LOG_ACTIVITY] Back button does NOT trigger BottomSheet');
  }

  void _navigateToSleepActivity(BuildContext context) async {
    debugPrint('[LOG_ACTIVITY] Navigating to SelectChildsScreen for Sleep Activity');
    debugPrint('[LOG_ACTIVITY] class_id: $_classId');
    debugPrint('[LOG_ACTIVITY] NOTE: BottomSheet will be opened from BOTTOM ACTION ICON, not from back button');
    
    // Navigate to SelectChildsScreen
    // The BottomSheet will be opened by the BOTTOM ACTION ICON in SelectChildsScreen
    // Back button will just navigate back without opening BottomSheet
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: _classId,
          activityType: 'sleep',
        ),
      ),
    );

    debugPrint('[LOG_ACTIVITY] Returning from SelectChildsScreen');
    debugPrint('[LOG_ACTIVITY] BottomSheet was opened from BOTTOM ACTION ICON (if user selected children)');
    debugPrint('[LOG_ACTIVITY] Back button does NOT trigger BottomSheet');
  }

  void _navigateToAccidentActivity(BuildContext context) async {
    debugPrint('[LOG_ACTIVITY] Navigating to SelectChildsScreen for Accident Activity');
    debugPrint('[LOG_ACTIVITY] class_id: $_classId');
    debugPrint('[LOG_ACTIVITY] NOTE: BottomSheet will be opened from BOTTOM ACTION ICON, not from back button');
    debugPrint('[LOG_ACTIVITY] NOTE: Accident Activity requires SINGLE child selection only');
    
    // Navigate to SelectChildsScreen
    // The BottomSheet will be opened by the BOTTOM ACTION ICON in SelectChildsScreen
    // Back button will just navigate back without opening BottomSheet
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildsScreen(
          returnSelectedChildren: true,
          classId: _classId,
          activityType: 'accident',
        ),
      ),
    );

    debugPrint('[LOG_ACTIVITY] Returning from SelectChildsScreen');
    debugPrint('[LOG_ACTIVITY] BottomSheet was opened from BOTTOM ACTION ICON (if user selected exactly 1 child)');
    debugPrint('[LOG_ACTIVITY] Back button does NOT trigger BottomSheet');
  }

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
                              onTap: () {
                                debugPrint('[LOG_ACTIVITY] ========== Entering Log Activity Meal flow ==========');
                                _navigateToMealActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.drink.image(height: 48),
                              title: 'Drink',
                              onTap: () {
                                debugPrint('[LOG_ACTIVITY] ========== Entering Log Activity Drink flow ==========');
                                _navigateToDrinkActivity(context);
                              },
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
                              onTap: () {
                                debugPrint('[LOG_ACTIVITY] ========== Entering Log Activity Bathroom flow ==========');
                                _navigateToBathroomActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.play.image(height: 48),
                              title: 'Play',
                              onTap: () {
                                debugPrint('[LOG_ACTIVITY] ========== Entering Log Activity Play flow ==========');
                                _navigateToPlayActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.sleep.image(height: 48),
                              title: 'Sleep',
                              onTap: () {
                                debugPrint('[LOG_ACTIVITY] ========== Entering Log Activity Sleep flow ==========');
                                _navigateToSleepActivity(context);
                              },
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
                              onTap: () {
                                debugPrint('[LOG_ACTIVITY] ========== Entering Log Activity Accident flow ==========');
                                _navigateToAccidentActivity(context);
                              },
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
