import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class BottomNavBar extends StatelessWidget {
  final TabsRouter tabsRouter;

  const BottomNavBar({super.key, required this.tabsRouter});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: DSColors.white,
      currentIndex: tabsRouter.activeIndex,
      onTap: (value) {
        tabsRouter.setActiveIndex(value);
      },
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/Search gray.png',
            width: 32,
            height: 32,
          ),
          activeIcon: Image.asset(
            'assets/images/Search.png',
            width: 32,
            height: 32,
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/Scan gray.png',
            width: 32,
            height: 32,
          ),
          activeIcon: Image.asset(
            'assets/images/Scan.png',
            width: 32,
            height: 32,
          ),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/My Cats gray.png',
            width: 32,
            height: 32,
          ),
          activeIcon: Image.asset(
            'assets/images/My Cats.png',
            width: 32,
            height: 32,
          ),
          label: 'My Cats',
        ),
      ],
    );
  }
}
