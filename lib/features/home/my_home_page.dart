import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/features/activity/activity_screen.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/appbar_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/widgets/bottom_navigation_bar_widget.dart';
import 'package:teacher_app/features/home/widgets/card_widget.dart';
import 'package:teacher_app/core/widgets/snackbar/custom_snackbar.dart';
import 'package:teacher_app/features/home/widgets/home_shimmer_widget.dart';
import 'package:teacher_app/features/messages/messages_screen.dart';
import 'package:teacher_app/features/home/widgets/profile_section_widget.dart';
import 'package:teacher_app/features/home/domain/entity/staff_class_session_entity.dart';
import 'package:teacher_app/features/staff_attendance/presentation/bloc/staff_attendance_bloc.dart';
import 'package:teacher_app/features/staff_attendance/presentation/time_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  static ValueNotifier<int> pageIndex = ValueNotifier(0);
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;
  bool _isInitialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    if (_isInitialDataLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final classId = prefs.getString(AppConstants.classIdKey);
    final contactId = prefs.getString('contact_id');
    final staffId = prefs.getString(AppConstants.staffIdKey);

    if (mounted && (classId != null || contactId != null)) {
      // فقط در صورت نیاز: PostLoginGuardScreen قبلاً GetLatestStaffAttendance صدا زده
      if (staffId != null && staffId.isNotEmpty) {
        final attendanceState = context.read<StaffAttendanceBloc>().state;
        if (attendanceState is! GetLatestStaffAttendanceSuccess) {
          context.read<StaffAttendanceBloc>().add(
            GetLatestStaffAttendanceEvent(staffId: staffId),
          );
        }
      }

      context.read<HomeBloc>().add(
        LoadHomeDataEvent(classId: classId, contactId: contactId),
      );
      _isInitialDataLoaded = true;
    }
  }

  /// Sync Time-In state with class session state
  /// Ensures no active session exists when teacher is Time-Out
  void _syncTimeInWithSession() {
    final attendanceState = context.read<StaffAttendanceBloc>().state;
    final homeState = context.read<HomeBloc>().state;

    // Check if teacher is Time-Out
    bool isTimeOut = false;
    if (attendanceState is GetLatestStaffAttendanceSuccess) {
      final latestAttendance = attendanceState.latestAttendance;
      isTimeOut =
          latestAttendance == null || latestAttendance.eventType != 'time_in';
    } else if (attendanceState is CreateStaffAttendanceSuccess) {
      isTimeOut = attendanceState.attendance.eventType == 'time_out';
    }

    // If Time-Out and active session exists, end it
    if (isTimeOut) {
      final session = homeState.session;
      if (_isClassSessionActive(session)) {
        final classId = homeState.session?.classId;
        if (session?.id != null && classId != null) {
          final endAt = DateFormat(
            'yyyy-MM-ddTHH:mm:ss',
          ).format(DateTime.now());
          context.read<HomeBloc>().add(
            UpdateSessionEvent(
              sessionId: session!.id!,
              endAt: endAt,
              classId: classId,
            ),
          );
        }
      }
    }
  }

  /// Check if class session is active (started but not ended)
  bool _isClassSessionActive(StaffClassSessionEntity? session) {
    if (session == null) return false;
    return session.startAt != null &&
        session.startAt!.isNotEmpty &&
        (session.endAt == null || session.endAt!.isEmpty);
  }

  // نگه داشتن صفحات برای جلوگیری از rebuild و درخواست مجدد API
  // استفاده از late final و ساخت در build برای دسترسی به context
  late final List<Widget> _homeTabPages = [
    Stack(
      children: [
        BackgroundWidget(),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [AppBarWidget(), ProfileSectionWidget(), CardWidget()],
            ),
          ),
        ),
      ],
    ),
    const TimeScreen(),
    const ActivityScreen(),
    const MessagesScreen(),
  ];

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    // اگر اولین بار است یا زمان زیادی از آخرین کلیک گذشته (بیش از 2 ثانیه)
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // اولین کلیک: نمایش SnackBar و جلوگیری از خروج
      _lastBackPressTime = now;
      CustomSnackbar.showInfo(context, 'Press back again to exit the app');
      return false; // جلوگیری از خروج
    } else {
      // دوباره کلیک شده در مدت زمان کوتاه: اجازه خروج
      return true; // اجازه خروج از اپ
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          SystemNavigator.pop(); // خروج از اپ
        }
      },
      child: MultiBlocListener(
        listeners: [
          // Sync Time-In with session state when attendance state changes
          BlocListener<StaffAttendanceBloc, StaffAttendanceState>(
            listener: (context, attendanceState) {
              // Sync when Time-Out is detected
              if (attendanceState is CreateStaffAttendanceSuccess &&
                  attendanceState.attendance.eventType == 'time_out') {
                _syncTimeInWithSession();
              } else if (attendanceState is GetLatestStaffAttendanceSuccess) {
                // Sync on app load if Time-Out detected
                final latestAttendance = attendanceState.latestAttendance;
                if (latestAttendance == null ||
                    latestAttendance.eventType != 'time_in') {
                  _syncTimeInWithSession();
                }
              }
            },
          ),
          // Sync when session is loaded
          BlocListener<HomeBloc, HomeState>(
            listener: (context, homeState) {
              // Only sync if session is loaded (not loading)
              if (!homeState.isLoadingSession && homeState.session != null) {
                _syncTimeInWithSession();
              }
            },
          ),
        ],
        child: Scaffold(
          body: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (prev, curr) =>
                prev.hasLoadedInitialDataOnce != curr.hasLoadedInitialDataOnce,
            builder: (context, state) {
              // بررسی اینکه آیا باید shimmer نمایش داده شود
              // از ابتدا shimmer نمایش داده می‌شود تا زمانی که داده‌های ضروری لود شوند
              final shouldShowShimmer = !state.hasLoadedInitialDataOnce;

              // اگر داده‌های ضروری هنوز لود نشده‌اند، shimmer نمایش بده
              if (shouldShowShimmer) {
                return const HomeShimmerWidget();
              }

              // در غیر این صورت، محتوای عادی را نمایش بده
              return ValueListenableBuilder(
                valueListenable: HomeScreen.pageIndex,
                builder: (context, value, child) {
                  // استفاده از IndexedStack برای نگه داشتن تمام صفحات
                  // این باعث می‌شود که initState فقط یک بار صدا زده شود
                  final index = value.clamp(0, _homeTabPages.length - 1);
                  return IndexedStack(index: index, children: _homeTabPages);
                },
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBarWidget(),
        ),
      ),
    );
  }
}
