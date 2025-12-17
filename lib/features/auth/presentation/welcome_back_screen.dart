import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/core/widgets/staff_avatar_widget.dart';
import 'package:teacher_app/features/auth/domain/entity/staff_class_entity.dart';
import 'package:teacher_app/features/auth/presentation/select_your_profile.dart';
import 'package:teacher_app/features/auth/presentation/teacher_login_screen.dart';
import 'package:teacher_app/features/home/my_home_page.dart';
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

  bool isLoading = false;

  Future<void> _login() async {
    if (passwordController.text.isEmpty || isLoading) return;

    setState(() => isLoading = true);

    final auth = ClerkAuth.of(context);

    try {
      await auth.attemptSignIn(
        strategy: Strategy.password,

        /// 🔹 identifier از کارمند انتخاب‌شده
        identifier: widget.staff.email,
        password: passwordController.text,
      );

      if (auth.isSignedIn && mounted) {
        final prefs = await SharedPreferences.getInstance();

        /// ✅ ذخیره وضعیت لاگین
        await prefs.setBool('is_logged_in', true);

        /// ✅ ذخیره کارمند انتخاب‌شده (برای بعداً)
        await prefs.setString('staff_id', widget.staff.staffId ?? '');
        await prefs.setString('staff_role', widget.staff.role ?? '');

        /// ✅ ذخیره contact_id و auth_mode
        await prefs.setString('contact_id', widget.staff.contactId ?? '');
        await prefs.setString('auth_mode', 'shared');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyHomePage()),
          (_) => false,
        );
      }
    } on AuthError catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

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

                      /// 🔹 Selected staff (changeable)
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
                              StaffAvatar(photoId: staff.photoId, size: 48),
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
                                    staff.role ?? '',
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
                        child: AbsorbPointer(
                          absorbing: isLoading,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ButtonWidget(
                                onTap: _login,
                                child: Text(
                                  isLoading ? '' : 'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isLoading)
                                const CupertinoActivityIndicator(
                                  color: Colors.white,
                                ),
                            ],
                          ),
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
