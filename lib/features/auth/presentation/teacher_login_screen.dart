import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/core/widgets/back_title_widget.dart';
import 'package:teacher_app/core/widgets/button_widget.dart';
import 'package:teacher_app/features/auth/domain/usecase/auth_usecase.dart';
import 'package:teacher_app/features/auth/presentation/post_login_guard_screen.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isRemember = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  /// خواندن ایمیل ذخیره‌شده
  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    final rememberFlag = prefs.getBool('remember_me') ?? false;

    if (rememberFlag && savedEmail != null) {
      emailController.text = savedEmail;
      setState(() => isRemember = true);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    setState(() => isLoading = true);

    final auth = ClerkAuth.of(context);

    try {
      await auth.attemptSignIn(
        strategy: Strategy.password,
        identifier: emailController.text.trim(),
        password: passwordController.text,
      );

      if (auth.isSignedIn && mounted) {
        final prefs = await SharedPreferences.getInstance();

        // ✅ ذخیره وضعیت لاگین
        await prefs.setBool('is_logged_in', true);

        // ✅ Remember Me logic
        if (isRemember) {
          await prefs.setString(
            'remembered_email',
            emailController.text.trim(),
          );
          await prefs.setBool('remember_me', true);
        } else {
          await prefs.remove('remembered_email');
          await prefs.setBool('remember_me', false);
        }

        // ✅ ذخیره auth_mode
        await prefs.setString('auth_mode', 'individual');

        // ✅ دریافت contact_id و class_id بر اساس email
        final authUsecase = getIt<AuthUsecase>();
        final result = await authUsecase.getContactIdAndClassIdByEmail(
          email: emailController.text.trim(),
        );

        if (result.data != null) {
          final contactId = result.data!['contact_id'];
          final classId = result.data!['class_id'];
          final staffId = result.data!['staff_id'];

          if (contactId != null && contactId.isNotEmpty) {
            await prefs.setString('contact_id', contactId);
          }

          if (classId != null && classId.isNotEmpty) {
            await prefs.setString('class_id', classId);
          }

          if (staffId != null && staffId.isNotEmpty) {
            await prefs.setString('staff_id', staffId);
          }
        }

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PostLoginGuardScreen()),
          (_) => false,
        );
      }
    } on AuthError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        BackTitleWidget(
                          title: 'Sign In',
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 40),
                        Assets.images.logoSample.image(height: 116),
                        const SizedBox(height: 24),
                        const Text(
                          'Teacher Login',
                          style: TextStyle(
                            color: Color(0xff444349),
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Sign in to manage your class',
                          style: TextStyle(
                            color: const Color(
                              0xff71717A,
                            ).withValues(alpha: .8),
                          ),
                        ),
                        const SizedBox(height: 48),

                        MailTextField(controller: emailController),
                        const SizedBox(height: 16),
                        PassTextField(controller: passwordController),
                        const SizedBox(height: 32),

                        RememberMeWidget(
                          value: isRemember,
                          onChanged: (v) => setState(() => isRemember = v),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class RememberMeWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RememberMeWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            value
                ? Assets.images.checkbox.svg()
                : Assets.images.checkbox2.svg(),
            const SizedBox(width: 12),
            const Text(
              'Remember Me',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MailTextField extends StatelessWidget {
  final TextEditingController controller;
  const MailTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xffEFEEF0),
          hintText: 'Email',
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Email is required';
          }
          return null;
        },
      ),
    );
  }
}

class PassTextField extends StatefulWidget {
  final TextEditingController controller;
  const PassTextField({super.key, required this.controller});

  @override
  State<PassTextField> createState() => _PassTextFieldState();
}

class _PassTextFieldState extends State<PassTextField> {
  bool isObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextFormField(
        controller: widget.controller,
        obscureText: isObscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xffEFEEF0),
          hintText: 'Password',
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          suffixIcon: IconButton(
            icon: const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() => isObscureText = !isObscureText);
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          return null;
        },
      ),
    );
  }
}
