import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';

/// Screen names for each tab index, matching [MainPage] tab order.
const _tabScreenNames = [
  SearchRoute.name,
  HomeRoute.name,
  CatListingRoute.name,
];

const _tabItems = [
  DSBottomNavItem(icon: Icons.search_rounded, label: 'Search'),
  DSBottomNavItem(icon: Icons.home_rounded, label: 'Home'),
  DSBottomNavItem(icon: Icons.pets_rounded, label: 'My cats'),
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
    return DSBottomNav(
      items: _tabItems,
      activeIndex: tabsRouter.activeIndex,
      onTap: (index) {
        tabsRouter.setActiveIndex(index);
        logScreenViewUsecase(screenName: _tabScreenNames[index]);
      },
    );
  }
}
