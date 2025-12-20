import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teacher_app/features/activity/activity_screen.dart';
import 'package:teacher_app/features/home/widgets/appbar_widget.dart';
import 'package:teacher_app/features/home/widgets/background_widget.dart';
import 'package:teacher_app/features/home/widgets/bottom_navigation_bar_widget.dart';
import 'package:teacher_app/features/home/widgets/card_widget.dart';
import 'package:teacher_app/features/messages/messages_screen.dart';
import 'package:teacher_app/features/profile/presentation/widgets/profile_section_widget.dart';
import 'package:teacher_app/features/time_screen/time_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  static ValueNotifier<int> pageIndex = ValueNotifier(0);
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _lastBackPressTime;

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
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          SystemNavigator.pop(); // خروج از اپ
        }
      },
      child: Scaffold(
      body: ValueListenableBuilder(
        valueListenable: MyHomePage.pageIndex,
        builder: (context, value, child) {
          if (value == 0) {
            return Stack(
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
            );
          } else if (value == 1) {
            return TimeScreen();
          } else if (value == 2) {
            return ActivityScreen();
          } else if (value == 3) {
            return MessagesScreen();
          } else {
            return Container();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
      ),
    );
  }
}
