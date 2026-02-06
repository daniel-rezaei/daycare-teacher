import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_accident_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_bathroom_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_drinks_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_incident_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_meals_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_mood_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_observation_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_play_api.dart';
import 'package:teacher_app/features/activity/data/data_source/activity_sleep_api.dart';
import 'package:teacher_app/features/activity/create_new_lessen_bottom_sheet.dart';
import 'package:teacher_app/features/activity/history_meal_screen.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/messages/select_childs_screen.dart';
import 'package:teacher_app/features/child_status/child_status.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  String? _classId;
  final Map<String, bool> _loadingStates = {};

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

  /// Check if history exists for the given activity type
  /// Calls the appropriate API based on activity type
  Future<bool> _hasActivityHistory(String activityType, String? classId) async {
    if (classId == null || classId.isEmpty) {
      debugPrint('[LOG_ACTIVITY] No classId provided, assuming no history');
      return false;
    }

    debugPrint(
      '[LOG_ACTIVITY] ========== Checking history for activity type: $activityType, classId: $classId ==========',
    );

    try {
      bool hasHistory = false;

      switch (activityType) {
        case 'meal':
          final api = GetIt.instance<ActivityMealsApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'drink':
          final api = GetIt.instance<ActivityDrinksApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'bathroom':
          final api = GetIt.instance<ActivityBathroomApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'play':
          final api = GetIt.instance<ActivityPlayApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'sleep':
          final api = GetIt.instance<ActivitySleepApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'accident':
          final api = GetIt.instance<ActivityAccidentApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'incident':
          final api = GetIt.instance<ActivityIncidentApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'observation':
          final api = GetIt.instance<ActivityObservationApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        case 'mood':
          final api = GetIt.instance<ActivityMoodApi>();
          hasHistory = await api.hasHistory(classId);
          break;
        default:
          debugPrint(
            '[LOG_ACTIVITY] Unknown activity type: $activityType, assuming no history',
          );
          return false;
      }

      debugPrint(
        '[LOG_ACTIVITY] ========== History check completed for $activityType: $hasHistory ==========',
      );
      return hasHistory;
    } catch (e, stackTrace) {
      debugPrint('[LOG_ACTIVITY] Error checking history for $activityType: $e');
      debugPrint('[LOG_ACTIVITY] StackTrace: $stackTrace');
      // On error, assume no history to show children list
      return false;
    }
  }

  Future<void> _navigateToActivity(
    BuildContext context,
    String activityType,
  ) async {
    // Set loading state to true
    setState(() {
      _loadingStates[activityType] = true;
    });

    try {
      final hasHistory = await _hasActivityHistory(activityType, _classId);

      if (hasHistory) {
        debugPrint(
          '[LOG_ACTIVITY] History exists, navigating to HistoryMealScreen for $activityType',
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryMealScreen(
              activityType: activityType,
              classId: _classId,
            ),
          ),
        );
      } else {
        debugPrint(
          '[LOG_ACTIVITY] No history, navigating to SelectChildsScreen for $activityType',
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectChildsScreen(
              returnSelectedChildren: true,
              classId: _classId,
              activityType: activityType,
            ),
          ),
        );
      }
    } finally {
      // Set loading state to false after navigation completes or fails
      if (mounted) {
        setState(() {
          _loadingStates[activityType] = false;
        });
      }
    }
  }

  void _navigateToMealActivity(BuildContext context) async {
    await _navigateToActivity(context, 'meal');
  }

  void _navigateToDrinkActivity(BuildContext context) async {
    await _navigateToActivity(context, 'drink');
  }

  void _navigateToBathroomActivity(BuildContext context) async {
    await _navigateToActivity(context, 'bathroom');
  }

  void _navigateToPlayActivity(BuildContext context) async {
    await _navigateToActivity(context, 'play');
  }

  void _navigateToSleepActivity(BuildContext context) async {
    await _navigateToActivity(context, 'sleep');
  }

  void _navigateToAccidentActivity(BuildContext context) async {
    await _navigateToActivity(context, 'accident');
  }

  void _navigateToIncidentActivity(BuildContext context) async {
    await _navigateToActivity(context, 'incident');
  }

  void _navigateToObservationActivity(BuildContext context) async {
    await _navigateToActivity(context, 'observation');
  }

  void _navigateToMoodActivity(BuildContext context) async {
    await _navigateToActivity(context, 'mood');
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
                              isLoading: _loadingStates['meal'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Meal flow ==========',
                                );
                                _navigateToMealActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.drink.image(height: 48),
                              title: 'Drink',
                              isLoading: _loadingStates['drink'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Drink flow ==========',
                                );
                                _navigateToDrinkActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.learn.image(height: 48),
                              title: 'Learn',
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Learn flow ==========',
                                );
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  useSafeArea: true,
                                  builder: (context) =>
                                      const CreateNewLessenBottomSheet(),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.bathroom.image(height: 48),
                              title: 'Bathroom',
                              isLoading: _loadingStates['bathroom'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Bathroom flow ==========',
                                );
                                _navigateToBathroomActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.play.image(height: 48),
                              title: 'Play',
                              isLoading: _loadingStates['play'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Play flow ==========',
                                );
                                _navigateToPlayActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.sleep.image(height: 48),
                              title: 'Sleep',
                              isLoading: _loadingStates['sleep'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Sleep flow ==========',
                                );
                                _navigateToSleepActivity(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.observation.image(height: 48),
                              title: 'Observation',
                              isLoading: _loadingStates['observation'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Observation flow ==========',
                                );
                                _navigateToObservationActivity(context);
                              },
                              isDisabled: false,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.incident.image(height: 48),
                              title: 'Incident',
                              isLoading: _loadingStates['incident'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Incident flow ==========',
                                );
                                _navigateToIncidentActivity(context);
                              },
                              isDisabled: false,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.accident.image(height: 48),
                              title: 'Accident',
                              isLoading: _loadingStates['accident'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Accident flow ==========',
                                );
                                _navigateToAccidentActivity(context);
                              },
                              isDisabled: false,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: InfoCardLogActivity(
                              icon: Assets.images.attendance.image(height: 48),
                              title: 'Attendance',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChildStatus(),
                                  ),
                                );
                              },
                              isDisabled: false,
                            ),
                          ),

                          /// ⭐⭐⭐ آیتم آخر – تمام عرض ⭐⭐⭐
                          SizedBox(
                            width: double.infinity,
                            child: InfoCardLogActivity(
                              icon: Assets.images.mood.image(height: 48),
                              title: 'Mood',
                              isLoading: _loadingStates['mood'] ?? false,
                              onTap: () {
                                debugPrint(
                                  '[LOG_ACTIVITY] ========== Entering Log Activity Mood flow ==========',
                                );
                                _navigateToMoodActivity(context);
                              },
                              isDisabled: false,
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
  final Function()? onTap;
  final bool isLoading;
  final bool isDisabled;

  const InfoCardLogActivity({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffFFFFFF),
            border: Border.all(color: const Color(0xffFAFAFA), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 8),
              isLoading
                  ? const CupertinoActivityIndicator(radius: 8)
                  : Text(
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
      ),
    );
  }
}
