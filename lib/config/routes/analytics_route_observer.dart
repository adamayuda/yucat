import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';

/// [NavigatorObserver] that tracks every route change as a Mixpanel "Screen View" event.
/// Uses the root [StackRouter]'s [currentSegments] so the visible (leaf) route is logged
/// (e.g. HomeRoute when inside MainRoute) instead of the parent route name.
class AnalyticsRouteObserver extends NavigatorObserver {
  final LogScreenViewUsecase _logScreenViewUsecase;
  final StackRouter _router;

  /// Routes that handle their own internal PageView tracking and should be excluded
  /// from automatic route tracking to prevent duplicate events.
  static const Set<String> _excludedRoutes = {
    'CreateCatRoute',
    'OnBoardingRoute',
  };

  AnalyticsRouteObserver({
    required LogScreenViewUsecase logScreenViewUsecase,
    required StackRouter router,
  }) : _logScreenViewUsecase = logScreenViewUsecase,
       _router = router;

  void _trackCurrentRoute(Route<dynamic>? route) {
    // Prefer leaf route from AutoRoute stack so we log e.g. HomeRoute, not MainRoute
    final segments = _router.currentSegments;
    final name = segments.isNotEmpty
        ? segments.last.name
        : route?.settings.name;

    // Skip tracking if this route handles its own PageView tracking
    if (name != null && name.isNotEmpty && !_excludedRoutes.contains(name)) {
      _logScreenViewUsecase.call(screenName: name);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackCurrentRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackCurrentRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackCurrentRoute(newRoute);
  }
}
