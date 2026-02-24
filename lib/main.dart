import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/locator/di.dart';
import 'package:teacher_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:teacher_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:teacher_app/features/auth/presentation/app_initial_screen.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_emergency_contact/presentation/bloc/child_emergency_contact_bloc.dart';
import 'package:teacher_app/features/child_guardian/presentation/bloc/child_guardian_bloc.dart';
import 'package:teacher_app/features/pickup_authorization/presentation/bloc/pickup_authorization_bloc.dart';
import 'package:teacher_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';
import 'package:teacher_app/features/staff_schedule/presentation/bloc/staff_schedule_bloc.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:teacher_app/features/class_transfer_request/presentation/bloc/class_transfer_request_bloc.dart';
import 'package:teacher_app/features/child_profile/presentation/bloc/child_profile_bloc.dart';
import 'package:teacher_app/core/services/attendance_session_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // locator مربوط به گت ایت و
  await configureDependencies(environment: Env.prod);

  // Initialize attendance session store (loads from persistent storage)
  await AttendanceSessionStore.instance.rehydrate();

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
        BlocProvider(create: (_) => getIt<HomeBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<ChildBloc>()),
        BlocProvider(create: (_) => getIt<AttendanceBloc>()),
        BlocProvider(create: (_) => getIt<PickupAuthorizationBloc>()),
        BlocProvider(create: (_) => getIt<StaffAttendanceBloc>()),
        BlocProvider(create: (_) => getIt<StaffScheduleBloc>()),
        BlocProvider(create: (_) => getIt<ChildGuardianBloc>()),
        BlocProvider(create: (_) => getIt<ChildEmergencyContactBloc>()),
        BlocProvider(create: (_) => getIt<ClassTransferRequestBloc>()),
        BlocProvider(create: (_) => getIt<ChildProfileBloc>()),
        BlocProvider(create: (_) => getIt<ActivityBloc>()),
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

        // اسپلش یکپارچه اول، سپس بر اساس لاگین به Welcome یا PostLoginGuard
        home: AppInitialScreen(isLoggedIn: isLoggedIn!),
      ),
    );
  }
}
