import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/core/services/time_in_access_guard.dart';
import 'package:teacher_app/features/activity/add_photo_screen.dart';
import 'package:teacher_app/features/activity/log_activity_screen.dart';
import 'package:teacher_app/features/activity/record_activity_screen.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String? classId;

  @override
  void initState() {
    super.initState();
    _loadClassId();
  }

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString(AppConstants.classIdKey);

    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
      });
      // Request class rooms if not already loaded
      final currentState = context.read<HomeBloc>().state;
      if (currentState.classRooms == null || currentState.classRooms!.isEmpty) {
        context.read<HomeBloc>().add(const LoadClassRoomsEvent());
      }
    }
  }

  String? _getRoomName(List<ClassRoomEntity>? classRooms) {
    if (classId == null || classRooms == null) return null;

    try {
      final classRoom = classRooms.firstWhere((room) => room.id == classId);
      return classRoom.roomName;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 34,
                  ),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      final roomName = _getRoomName(state.classRooms);
                      return Row(
                        children: [
                          Text(
                            'Activity',
                            style: TextStyle(
                              color: Color(0xff444349),
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (roomName != null) ...[
                            Text(
                              ' – ',
                              style: TextStyle(
                                color: Color(0xff444349),
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (state.isLoadingClassRooms)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CupertinoActivityIndicator(radius: 8),
                              )
                            else
                              Text(
                                roomName,
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        topLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -4),
                          blurRadius: 16,
                          color: Color(0xff000000).withValues(alpha: .1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Assets.images.dateIconPng.image(height: 198),
                              Positioned(
                                top: MediaQuery.of(context).size.height * 0.08,
                                child: Column(
                                  children: [
                                    Text(
                                      'Sun',
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '8',
                                      style: TextStyle(
                                        color: Color(0xff7B2AF3),
                                        fontSize: 60,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 48),
                          GestureDetector(
                            onTap: () {
                              TimeInAccessGuard.guardNavigation(context, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecordActivityScreen(),
                                  ),
                                );
                              });
                            },
                            child: Assets.images.infoCardPng.image(),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              TimeInAccessGuard.guardNavigation(context, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LogActivityScreen(),
                                  ),
                                );
                              });
                            },
                            child: Assets.images.infoCard2.image(),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              TimeInAccessGuard.guardNavigation(context, () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddPhotoScreen(),
                                  ),
                                );
                              });
                            },
                            child: Assets.images.infoCard3.image(),
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
