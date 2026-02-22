import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';

/// Screen names for each tab index, matching [MainPage] tab order.
const _tabScreenNames = [
  SearchRoute.name,
  HomeRoute.name,
  CatListingRoute.name,
];

class BottomNavBar extends StatelessWidget {
  final TabsRouter tabsRouter;
  final LogScreenViewUsecase logScreenViewUsecase;

  const BottomNavBar({
    super.key,
    required this.tabsRouter,
    required this.logScreenViewUsecase,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: DSColors.white,
      currentIndex: tabsRouter.activeIndex,
      onTap: (index) {
        tabsRouter.setActiveIndex(index);
        logScreenViewUsecase(screenName: _tabScreenNames[index]);
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
