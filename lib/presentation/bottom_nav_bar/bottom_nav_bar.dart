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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'My Cats'),
      ],
    );
  }
}
