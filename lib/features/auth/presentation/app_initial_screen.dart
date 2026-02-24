import 'package:flutter/material.dart';
import 'package:teacher_app/core/widgets/app_loading_screen.dart';
import 'package:teacher_app/features/auth/presentation/post_login_guard_screen.dart';
import 'package:teacher_app/features/auth/presentation/welcome_screen.dart';

/// اولین صفحهٔ اپ بعد از اجرا. اسپلش برندشده نشان می‌دهد تا هماهنگ با Clerk و آماده‌سازی
/// باشد، سپس بدون نمایش صفحه سیاه به Welcome یا PostLoginGuard می‌رود.
class AppInitialScreen extends StatefulWidget {
  const AppInitialScreen({
    super.key,
    required this.isLoggedIn,
  });

  final bool isLoggedIn;

  @override
  State<AppInitialScreen> createState() => _AppInitialScreenState();
}

class _AppInitialScreenState extends State<AppInitialScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterReady();
  }

  Future<void> _navigateAfterReady() async {
    // حداقل زمان نمایش اسپلش برای تجربه روان و یکپارچه
    const minSplashDuration = Duration(milliseconds: 1200);
    await Future.delayed(minSplashDuration);

    if (!mounted) return;

    final next = widget.isLoggedIn
        ? const PostLoginGuardScreen()
        : const WelcomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppLoadingScreen();
  }
}
