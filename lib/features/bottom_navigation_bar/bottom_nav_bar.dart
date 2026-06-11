import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';

/// Screen names for each tab index, matching [MainPage] tab order.
const _tabScreenNames = [
  SearchRoute.name,
  HomeRoute.name,
  ProfileRoute.name,
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
    final l10n = AppLocalizations.of(context);
    final items = [
      DSBottomNavItem(icon: Icons.search_rounded, label: l10n.bottomNavSearch),
      DSBottomNavItem(icon: Icons.home_rounded, label: l10n.bottomNavHome),
      DSBottomNavItem(icon: Icons.person_rounded, label: l10n.bottomNavProfile),
    ];
    return DSBottomNav(
      items: items,
      activeIndex: tabsRouter.activeIndex,
      onTap: (index) {
        tabsRouter.setActiveIndex(index);
        logScreenViewUsecase(screenName: _tabScreenNames[index]);
      },
    );
  }
}
