import 'package:flutter/material.dart';
import 'package:teacher_app/features/home/my_home_page.dart';
import 'package:teacher_app/features/home/widgets/tab_bottom_navigation_bar.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 32,
            color: Color(0xff4B3425).withValues(alpha: .12),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: ValueListenableBuilder(
        valueListenable: MyHomePage.pageIndex,
        builder: (context, value, child) {
          return Row(
            children: [
              TabBottomNavigationBar(
                onTap: () => MyHomePage.pageIndex.value = 0,
                icon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: value == 0
                      ? Assets.images.homeSmileFill.svg()
                      : Assets.images.homeSmileOutline.svg(),
                ),
                isActive: value == 0 ? true : false,
              ),
              TabBottomNavigationBar(
                onTap: () => MyHomePage.pageIndex.value = 1,
                icon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: value == 1
                      ? Assets.images.timeOut.svg()
                      : Assets.images.aIconN1.svg(),
                ),
                isActive: value == 1 ? true : false,
              ),
              TabBottomNavigationBar(
                onTap: () => MyHomePage.pageIndex.value = 2,
                icon: value == 2
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Assets.images.xFill.svg(),
                      )
                    : Assets.images.group.image(),
                isActive: value == 2 ? true : false,
              ),
              TabBottomNavigationBar(
                onTap: () => MyHomePage.pageIndex.value = 3,
                icon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: value == 3
                      ? Assets.images.chatRoundLineFill.svg()
                      : Assets.images.chatRoundLineOutline.svg(),
                ),
                isActive: value == 3 ? true : false,
              ),
              TabBottomNavigationBar(
                onTap: () => MyHomePage.pageIndex.value = 4,
                icon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Assets.images.aIconNSvg.svg(),
                ),
                isActive: value == 4 ? true : false,
              ),
            ],
          );
        },
      ),
    );
  }
}
