import 'package:auto_route/auto_route.dart';
import 'package:yucat/features/cat_listing/cat_listing_page.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/cat_create/create_cat_page.dart';
import 'package:yucat/features/cat_detail/presentation/cat_detail_page.dart';
import 'package:yucat/features/onboarding/onboarding_page.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/profile/profile_page.dart';
import 'package:yucat/features/saved_products/presentation/saved_products_page.dart';
import 'package:yucat/features/search_products/presentation/search_page.dart';
import 'package:yucat/features/home/home_page.dart';
import 'package:yucat/features/home/scanner_page.dart';
import 'package:yucat/features/product_detail/presentation/product_detail_page.dart';
import 'package:yucat/features/product_listing/presentation/product_listing_page.dart';
import 'package:yucat/features/paywall/paywall_page.dart';
import 'package:yucat/presentation/main/main_page.dart';
import 'package:yucat/features/splash/presentation/splash_page.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

/// Plain horizontal slide on an easeInOutCubic curve with no fade — matches
/// the onboarding PageView's `animateToPage` so the hand-off into the
/// cat-create wizard doesn't visually stand out from the rest of onboarding.
Widget _slideLeftCubic(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic,
  );
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(curved),
    child: child,
  );
}

/// Onboarding route transition. The primary (entry) animation is intentionally
/// a no-op — onboarding replaces the splash screen and should appear without a
/// flourish. The secondary animation slides the whole onboarding view out to
/// the left as the cat-create wizard is pushed over it, in lockstep with the
/// wizard sliding in (`_slideLeftCubic`) so the hand-off reads as one
/// coordinated page slide.
///
/// This is a `CustomRoute` precisely so onboarding does NOT get the platform's
/// built-in "covered page" parallax (the iOS Cupertino route shifts the
/// underlying page ~1/3 width). Stacking that on top of this full-width slide
/// is what produced a black gap between the two screens mid-transition.
Widget _onboardingTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeInOutCubic,
  );
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(curved),
    child: child,
  );
}

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),
    CustomRoute(
      page: OnBoardingRoute.page,
      path: '/onboarding',
      durationInMilliseconds: 280,
      reverseDurationInMilliseconds: 280,
      transitionsBuilder: _onboardingTransition,
    ),
    AutoRoute(
      page: MainRoute.page,
      path: '/main',
      children: [
        AutoRoute(page: SearchRoute.page, path: 'search'),
        AutoRoute(page: HomeRoute.page, path: 'home'),
        AutoRoute(page: CatListingRoute.page, path: 'cats'),
      ],
    ),
    AutoRoute(
      page: ScannerRoute.page,
      path: '/scanner',
      fullscreenDialog: true,
    ),
    AutoRoute(page: ProductDetailRoute.page, path: '/product-detail'),
    AutoRoute(page: ProductListingRoute.page, path: '/product-listing'),
    AutoRoute(page: ProfileRoute.page, path: '/profile'),
    AutoRoute(page: SavedProductsRoute.page, path: '/saved-products'),
    CustomRoute(
      page: CreateCatRoute.page,
      path: '/cats/create',
      durationInMilliseconds: 280,
      reverseDurationInMilliseconds: 280,
      transitionsBuilder: _slideLeftCubic,
    ),
    AutoRoute(page: CatDetailRoute.page, path: '/cats/detail'),
    CustomRoute(
      page: PaywallRoute.page,
      path: '/paywall',
      fullscreenDialog: true,
      opaque: false,
      transitionsBuilder: TransitionsBuilders.slideBottom,
    ),
  ];
}
