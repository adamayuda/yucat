import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:yucat/features/cat_create/bloc/cat_create_bloc.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';

import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:yucat/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:yucat/features/product_listing/presentation/bloc/product_listing_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/search_products/presentation/bloc/search_bloc.dart';
import 'package:yucat/service_locator.dart';

import 'config/routes/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Configure RevenueCat for iOS
  if (Platform.isIOS) {
    await _configureRevenueCat();
  }

  await initializeDependencies();

  runApp(App());
}

Future<void> _configureRevenueCat() async {
  // Enable debug logs before calling `configure`.
  await Purchases.setLogLevel(LogLevel.debug);

  // Configure RevenueCat for iOS
  const appleApiKey = 'appl_RLrrtMqNXWlaNlEXzZQxUcxkJxw';

  final configuration = PurchasesConfiguration(appleApiKey)
    ..appUserID = null
    ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();

  await Purchases.configure(configuration);
}

class App extends StatelessWidget {
  final _appRouter = AppRouter();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<OnBoardingBloc>()),
        BlocProvider(create: (context) => sl<SearchBloc>()),
        BlocProvider(create: (context) => sl<HomeBloc>()),
        BlocProvider(create: (context) => sl<ProfileBloc>()),
        BlocProvider(create: (context) => sl<ProductDetailBloc>()),
        BlocProvider(create: (context) => sl<CatListingBloc>()),
        BlocProvider(create: (context) => sl<CatCreateBloc>()),
        BlocProvider(create: (context) => sl<ProductListingBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // localizationsDelegates: AppLocalizations.localizationsDelegates,
        // supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
