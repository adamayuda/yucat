import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/cat_detail/presentation/bloc/cat_detail_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/splash/presentation/bloc/splash_bloc.dart';
import 'firebase_options.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';

import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:yucat/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:yucat/features/product_listing/presentation/bloc/product_listing_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:yucat/features/saved_products/presentation/bloc/saved_products_bloc.dart';
import 'package:yucat/features/scan_history/presentation/bloc/scan_history_bloc.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/remote_config_service.dart';

import 'config/routes/analytics_route_observer.dart';
import 'config/routes/router.dart';
import 'package:yucat/features/litter_detail/presentation/bloc/litter_detail_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure RevenueCat on iOS + Android (hard paywall enforced on both).
  if (Platform.isIOS || Platform.isAndroid) {
    await _configureRevenueCat();
  }

  await initializeDependencies();

  // Pull remote kill switches before the UI starts. Fail-open: a failure leaves
  // the in-app defaults (everything enabled) in place.
  await sl<RemoteConfigService>().initialize();

  // Initialise OneSignal (iOS only). Does not prompt for permission — that is
  // deferred to the onboarding reminders screen.
  if (Platform.isIOS) {
    await sl<NotificationService>().initialize();
  }

  runApp(App());
}

Future<void> _configureRevenueCat() async {
  // Enable debug logs before calling `configure`.
  await Purchases.setLogLevel(LogLevel.debug);

  // Public SDK keys (safe to commit). iOS = App Store, Android = Google Play.
  const appleApiKey = 'appl_RLrrtMqNXWlaNlEXzZQxUcxkJxw';
  // RevenueCat Android public SDK key (Google Play).
  const googleApiKey = 'goog_RiTqfgyAOTSPvSLQjnBszSTXAKK';

  final apiKey = Platform.isIOS ? appleApiKey : googleApiKey;

  final configuration = PurchasesConfiguration(apiKey)
    ..appUserID = null
    ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();

  await Purchases.configure(configuration);
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final _appRouter = AppRouter();

  void _logAppOpened(String launchType) {
    final hasOnboarded = sl<SharedPreferences>().getBool('onboarding_completed') ?? false;
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.appOpened,
      properties: {
        'launch_type': launchType,
        'is_first_launch': !hasOnboarded,
        'platform': Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other'),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logAppOpened('cold');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _logAppOpened('warm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<OnBoardingBloc>()),
        BlocProvider(create: (context) => sl<HomeBloc>()),
        BlocProvider(create: (context) => sl<ProfileBloc>()),
        BlocProvider(create: (context) => sl<RecipesBloc>()),
        BlocProvider(create: (context) => sl<ProductDetailBloc>()),
        BlocProvider(create: (context) => sl<LitterDetailBloc>()),
        BlocProvider(create: (context) => sl<SavedProductsBloc>()),
        BlocProvider(create: (context) => sl<ScanHistoryBloc>()),
        BlocProvider(create: (context) => sl<CatListingBloc>()),
        // CatCreateBloc is intentionally NOT provided here — CreateCatPage owns
        // a fresh instance per session so wizard state never leaks across runs.
        BlocProvider(create: (context) => sl<CatDetailBloc>()),
        BlocProvider(create: (context) => sl<ProductListingBloc>()),
        BlocProvider(create: (context) => sl<PaywallBloc>()),
        BlocProvider(create: (context) => sl<SplashBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Flutter's default falls back to supportedLocales.first, and the
        // generated list is alphabetical — so an unmatched device language
        // would resolve to GERMAN. Harmless for chrome, but recipes are served
        // per language from Firestore, so it would hand a Japanese user German
        // recipes. Fall back to English explicitly.
        localeResolutionCallback: (locale, supported) {
          if (locale != null) {
            for (final candidate in supported) {
              if (candidate.languageCode == locale.languageCode) {
                return candidate;
              }
            }
          }
          return const Locale('en');
        },
        routerConfig: _appRouter.config(
          navigatorObservers: () => [
            ...AutoRouterDelegate.defaultNavigatorObserversBuilder(),
            AnalyticsRouteObserver(
              logScreenViewUsecase: sl<LogScreenViewUsecase>(),
              router: _appRouter,
            ),
          ],
        ),
      ),
    );
  }
}
