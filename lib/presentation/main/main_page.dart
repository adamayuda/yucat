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
      routes: const [SearchRoute(), HomeRoute(), ProfileRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final bottomInset = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: Colors.transparent,
          // The nav floats over the page in a Stack rather than occupying a
          // bottomNavigationBar slot, so each tab paints full-bleed to the
          // bottom edge. A soft fade behind the pill lets scrolling content
          // dissolve into the tint instead of being clipped by a solid bar —
          // mirroring the onboarding floating-CTA fade.
          body: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: bottomInset + 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          DSColors.tintLavender.withValues(alpha: 0),
                          DSColors.tintLavender,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
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
