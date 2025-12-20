import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/features/activity/activity_screen.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/appbar_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/widgets/bottom_navigation_bar_widget.dart';
import 'package:teacher_app/features/home/widgets/card_widget.dart';
import 'package:teacher_app/features/home/widgets/home_shimmer_widget.dart';
import 'package:teacher_app/features/messages/messages_screen.dart';
import 'package:teacher_app/features/profile/presentation/widgets/profile_section_widget.dart';
import 'package:teacher_app/features/staff_attendance/presentation/time_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  static ValueNotifier<int> pageIndex = ValueNotifier(0);
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _lastBackPressTime;
  bool _hasLoadedData = false;
  
  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    if (_hasLoadedData) return;
    
    final prefs = await SharedPreferences.getInstance();
    final classId = prefs.getString(AppConstants.classIdKey);
    final contactId = prefs.getString('contact_id');
    
    if (mounted && (classId != null || contactId != null)) {
      context.read<HomeBloc>().add(LoadHomeDataEvent(
        classId: classId,
        contactId: contactId,
      ));
      _hasLoadedData = true;
    }
  }
  
  // نگه داشتن صفحات برای جلوگیری از rebuild و درخواست مجدد API
  // استفاده از late final و ساخت در build برای دسترسی به context
  late final List<Widget> _pages = [
    Stack(
      children: [
        BackgroundWidget(),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppbarWidget(),
                ProfileSectionWidget(),
                CardWidget(),
              ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اگر می‌خواهید از اپ خارج شوید، دوباره دکمه back را بزنید'),
          duration: Duration(seconds: 2),
        ),
      );
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
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
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
              valueListenable: MyHomePage.pageIndex,
              builder: (context, value, child) {
                // استفاده از IndexedStack برای نگه داشتن تمام صفحات
                // این باعث می‌شود که initState فقط یک بار صدا زده شود
                final index = value.clamp(0, _pages.length - 1);
                return IndexedStack(
                  index: index,
                  children: _pages,
                );
              },
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBarWidget(),
      ),
    );
  }
}
