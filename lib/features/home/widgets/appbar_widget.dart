import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class AppbarWidget extends StatefulWidget {
  const AppbarWidget({super.key});

  @override
  State<AppbarWidget> createState() => _AppbarWidgetState();
}

class _AppbarWidgetState extends State<AppbarWidget> {
  String? classId;

  @override
  void initState() {
    super.initState();
    _loadClassId();
  }

  Future<void> _loadClassId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClassId = prefs.getString('class_id');
    
    debugPrint('[APPBAR_DEBUG] Loading classId: $savedClassId');
    
    if (mounted && savedClassId != null && savedClassId.isNotEmpty) {
      setState(() {
        classId = savedClassId;
      });
      // فقط در صورتی که state قبلاً success نبوده باشد
      final currentState = context.read<AuthBloc>().state;
      if (currentState is! GetClassRoomsSuccess) {
        debugPrint('[APPBAR_DEBUG] Requesting GetClassRoomsEvent');
        context.read<AuthBloc>().add(const GetClassRoomsEvent());
      } else {
        debugPrint('[APPBAR_DEBUG] ClassRooms already loaded');
      }
    } else {
      debugPrint('[APPBAR_DEBUG] classId is null or empty');
    }
  }

  String? _getRoomName(List<ClassRoomEntity> classRooms) {
    if (classId == null) return null;
    
    try {
      final classRoom = classRooms.firstWhere(
        (room) => room.id == classId,
      );
      return classRoom.roomName;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? roomName;

        debugPrint('[APPBAR_DEBUG] AuthState: ${state.runtimeType}');

        if (state is GetClassRoomsSuccess) {
          roomName = _getRoomName(state.classRooms);
          debugPrint('[APPBAR_DEBUG] Room name: $roomName');
        } else if (state is GetClassRoomsFailure) {
          debugPrint('[APPBAR_DEBUG] GetClassRoomsFailure: ${state.message}');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Home',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff444349),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffFFFFFF).withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 2, color: const Color(0xffFAFAFA)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: const Color(0xffE4D3FF).withValues(alpha: .5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Assets.images.leftSlotItems.svg(),
                    const SizedBox(width: 8),
                    if (state is GetClassRoomsLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CupertinoActivityIndicator(
                          radius: 8,
                        ),
                      )
                    else
                      Text(
                        roomName ?? '',
                        style: const TextStyle(
                          color: Color(0xff681AD6),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
