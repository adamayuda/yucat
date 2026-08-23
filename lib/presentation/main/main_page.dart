import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/bottom_navigation_bar/bottom_nav_bar.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [HomeRoute(), RecipesRoute(), ProfileRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          // Opaque tint behind the tabs: AutoTabsRouter cross-fades between
          // tabs, and during the fade both pages are partially transparent —
          // a transparent Scaffold would let the black window show through
          // (a black blink). pageBackground matches the Recipes/Profile
          // scaffolds.
          backgroundColor: DSColors.pageBackground,
          // The nav floats over the page in a Stack rather than occupying a
          // bottomNavigationBar slot, so each tab paints full-bleed to the
          // bottom edge and its content scrolls *under* the nav — which is
          // what the nav's BackdropFilter frosts. Deliberately no gradient
          // fade here: an opaque fade would be all the blur ever saw.
          body: Stack(
            children: [
              Positioned.fill(child: child),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomNavBar(
                  tabsRouter: tabsRouter,
                  logScreenViewUsecase: sl<LogScreenViewUsecase>(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
