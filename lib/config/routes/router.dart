import 'package:auto_route/auto_route.dart';
import 'package:yucat/features/cat_listing/presentation/cat_listing_page.dart';
import 'package:yucat/features/cat_create/presentation/create_cat_page.dart';
import 'package:yucat/features/onboarding/onboarding_page.dart';
import 'package:yucat/features/product_detail/presentation/models/product_model.dart';
import 'package:yucat/features/profile/profile_page.dart';
import 'package:yucat/features/search/presentation/search_page.dart';
import 'package:yucat/features/home/home_page.dart';
import 'package:yucat/features/product_detail/product_detail_page.dart';
import 'package:yucat/presentation/main/main_page.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: OnBoardingRoute.page, path: '/'),
    AutoRoute(
      page: MainRoute.page,
      path: '/main',
      children: [
        AutoRoute(page: SearchRoute.page, path: 'search'),
        AutoRoute(page: HomeRoute.page, path: 'home'),
        AutoRoute(page: CatListingRoute.page, path: 'cats'),
      ],
    ),
    AutoRoute(page: ProductDetailRoute.page, path: '/product-detail'),
    AutoRoute(page: ProfileRoute.page, path: '/profile'),
    AutoRoute(
      page: CreateCatRoute.page,
      path: '/cats/create',
      fullscreenDialog: true,
    ),
  ];
}
