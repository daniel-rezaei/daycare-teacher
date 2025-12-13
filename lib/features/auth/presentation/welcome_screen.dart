import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/features/auth/domain/entity/class_room_entity.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/features/auth/presentation/select_class_screen.dart';
import 'package:teacher_app/features/auth/presentation/teacher_login_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<ClassRoomEntity>? classRooms;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetClassRoomsEvent());
  }

  bool get isSharedReady => classRooms != null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is GetClassRoomsSuccess) {
          setState(() {
            classRooms = state.classRooms;
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 290),
                child: Assets.images.illustration.image(),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          color: Color(0xff6D6B76),
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Daycare',
                        style: TextStyle(
                          color: Color(0xff9C5CFF),
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// 🔹 Shared Mode
                      InfoCardWelcome(
                        icon: isSharedReady
                            ? Assets.images.sharedMode.svg()
                            : const CupertinoActivityIndicator(),
                        title: 'Shared Mode',
                        onTap: isSharedReady
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SelectClassScreen(
                                      classRooms: classRooms!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),

                      const SizedBox(height: 24),

                      /// 🔹 Individual Mode
                      InfoCardWelcome(
                        icon: Assets.images.individualMode.svg(),
                        title: 'Individual Mode',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherLoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCardWelcome extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback? onTap;

  const InfoCardWelcome({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 2, color: const Color(0xffFAFAFA)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffE4D3FF).withValues(alpha: .5),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff444349),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Assets.images.iconButton2.svg(),
            ],
          ),
        ),
      ),
    );
  }
}
