import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/features/auth/presentation/welcome_screen.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/home/my_home_page.dart';
import 'package:teacher_app/features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // locator مربوط به گت ایت و
  await configureDependencies(environment: Env.prod);
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(
    ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey:
            'pk_test_dml0YWwtc2hpbmVyLTgyLmNsZXJrLmFjY291bnRzLmRldiQ',
      ),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

/* ---------------- App ---------------- */

class MyApp extends StatelessWidget {
  final bool? isLoggedIn;
  const MyApp({super.key, this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<ChildBloc>()),
      ],
      child: MaterialApp(
        title: 'Teacher App',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.interTextTheme(),
        ),

        // 🚀 تصمیم فقط با Shared
        home: isLoggedIn! ? const MyHomePage() : const WelcomeScreen(),
      ),
    );
  }
}
