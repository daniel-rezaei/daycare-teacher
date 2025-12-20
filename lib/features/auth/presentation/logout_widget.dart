import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/features/auth/presentation/welcome_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class LogoutWidget extends StatefulWidget {
  const LogoutWidget({super.key});

  @override
  State<LogoutWidget> createState() => _LogoutWidgetState();
}

class _LogoutWidgetState extends State<LogoutWidget> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    debugPrint('[LOGOUT] 🔘 Logout tapped');

    try {
      // 1️⃣ Clerk logout
      final auth = ClerkAuth.of(context);
      debugPrint('[LOGOUT] 🔐 Signing out from Clerk...');
      await auth.signOut();
      debugPrint('[LOGOUT] ✅ Clerk signOut done');

      // 2️⃣ Clear SharedPreferences
      debugPrint('[LOGOUT] 🧹 Clearing SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      debugPrint('[LOGOUT] ✅ is_logged_in removed');

      // 3️⃣ Navigate to Welcome (clear stack)
      if (!mounted) return;

      debugPrint('[LOGOUT] 🚪 Navigating to WelcomeScreen');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    } catch (e, s) {
      debugPrint('[LOGOUT] ❌ Logout failed');
      debugPrint('[LOGOUT] ❌ error: $e');
      debugPrint('[LOGOUT] ❌ stack: $s');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logout failed')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('[LOGOUT] ⏹ Logout flow finished');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Row(
                children: [
                  Assets.images.logout.svg(),
                  const SizedBox(width: 8),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xff6D6B76),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Assets.images.iconButton.svg(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xffDBDADD)),
            const SizedBox(height: 20),
            Assets.images.exitDuotone.svg(),
            const SizedBox(height: 24),
            const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sign out of your account and return to the login screen.',
              style: TextStyle(color: Color(0xff444349), fontSize: 12),
            ),
            const SizedBox(height: 40),

            // 🔴 Logout button
            GestureDetector(
              onTap: _isLoading ? null : _handleLogout,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xff9C5CFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: _isLoading
                    ? const CupertinoActivityIndicator(
                        radius: 10,
                        color: Colors.white,
                      )
                    : const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xffFAFAFA),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Cancel
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffDBDADD)),
                ),
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xff6D6B76),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
