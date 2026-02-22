import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/bottom_navigation_bar/bottom_nav_bar.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [SearchRoute(), HomeRoute(), CatListingRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavBar(
            tabsRouter: tabsRouter,
            logScreenViewUsecase: sl<LogScreenViewUsecase>(),
          ),
        );
      },
    );
  }
}
