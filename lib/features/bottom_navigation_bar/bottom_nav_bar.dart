import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';

/// The nav has four slots but [MainPage] only has three tabs — Scan is an
/// action that pushes [ScannerRoute], not a tab. These two tables are the
/// mapping between them; `-1` marks the action slot.
const _kScanSlot = 1;
const _slotToTab = [0, -1, 1, 2];
const _tabToSlot = [0, 2, 3];

/// Screen names per tab index, matching [MainPage] tab order.
const _tabScreenNames = [
  HomeRoute.name,
  RecipesRoute.name,
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
      DSBottomNavItem(icon: Icons.home_rounded, label: l10n.bottomNavHome),
      DSBottomNavItem(icon: Icons.crop_free_rounded, label: l10n.bottomNavScan),
      DSBottomNavItem(
        icon: Icons.ramen_dining_rounded,
        label: l10n.bottomNavRecipes,
      ),
      DSBottomNavItem(icon: Icons.person_rounded, label: l10n.bottomNavProfile),
    ];
    return DSBottomNav(
      items: items,
      activeIndex: _tabToSlot[tabsRouter.activeIndex],
      onTap: (slot) {
        if (slot == _kScanSlot) {
          // Switch to Home first: HomeBloc emits HomeScanningState once the
          // photo is captured, and the scan theater only paints while Home is
          // the active tab. No screen-view log here — AnalyticsRouteObserver
          // already emits one for ScannerRoute.
          tabsRouter.setActiveIndex(_slotToTab[0]);
          context.router.push(ScannerRoute());
          return;
        }
        final tab = _slotToTab[slot];
        tabsRouter.setActiveIndex(tab);
        logScreenViewUsecase(screenName: _tabScreenNames[tab]);
      },
    );
  }
}
