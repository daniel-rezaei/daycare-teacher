import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/presentation/select_your_profile.dart';
import 'package:teacher_app/features/auth/presentation/teacher_login_screen.dart';
import 'package:teacher_app/features/auth/presentation/time_in_screen.dart';
import 'package:teacher_app/features/personal_information/personal_information_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class WelcomeBackScreen extends StatefulWidget {
  final StaffClassEntity staff;
  final String classId;
  final List<StaffClassEntity> staffClasses;

  const WelcomeBackScreen({
    super.key,
    required this.staff,
    required this.classId,
    required this.staffClasses,
  });

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      BackTitleWidget(
                        title: 'Sign In',
                        onTap: () => Navigator.pop(context),
                      ),

                      const SizedBox(height: 40),
                      Assets.images.logoSample.image(height: 116),
                      const SizedBox(height: 24),

                      /// 🔹 Welcome text
                      Text(
                        'Welcome ${staff.firstName}',
                        style: const TextStyle(
                          color: Color(0xff444349),
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Please sign in to continue',
                        style: TextStyle(
                          color: const Color(0xff71717A).withValues(alpha: .8),
                        ),
                      ),

                      const SizedBox(height: 48),

                      /// 🔹 Selected staff card (clickable)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SelectYourProfileScreen(
                                classId: widget.classId,
                                staffClasses: widget.staffClasses,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffF0E7FF),
                            border: Border.all(
                              width: 2,
                              color: const Color(0xffFAFAFA),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            children: [
                              Assets.images.image.image(height: 48),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${staff.firstName} ${staff.lastName}',
                                    style: const TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    staff.role,
                                    style: const TextStyle(
                                      color: Color(0xff71717A),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Assets.images.checkbox.svg(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 🔹 Password
                      PassTextField(controller: passwordController),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.images.subtract3.svg(),
                          const SizedBox(width: 8),
                          const Text(
                            'Sign in with Face ID',
                            style: TextStyle(
                              color: Color(0xff444349),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
                        child: ButtonWidget(
                          title: 'Log In',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TimeInScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xff444349),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
