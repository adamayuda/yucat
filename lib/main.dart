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
import 'package:flutter/foundation.dart';
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
import 'package:yucat/services/session_replay_service.dart';
import 'package:yucat/services/user_analytics_service.dart';
// `show` scoped: the package also exports a `LogLevel` that collides with
// RevenueCat's, used by `_configureRevenueCat` below.
import 'package:mixpanel_flutter_session_replay/mixpanel_flutter_session_replay.dart'
    show MixpanelSessionReplay, MixpanelSessionReplayWidget;

import 'config/build_env.dart';
import 'config/routes/analytics_route_observer.dart';
import 'config/routes/router.dart';
import 'package:yucat/features/litter_detail/presentation/bloc/litter_detail_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _installErrorHandlers();

  // Resolved before runApp so `kQaToolsEnabled` is final by the first build.
  // It gates the Profile reset-onboarding row and the paywall escape hatch,
  // both of which must reach TestFlight but not the App Store.
  await resolveBuildEnvironment();

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

  // Awaited BEFORE runApp on purpose. `MixpanelSessionReplayWidget` renders its
  // child bare while the instance is null, then wraps it in three widgets once
  // one arrives — a different widget type in that slot, so Flutter unmounts the
  // whole app subtree and rebuilds it. That closes every root bloc while live
  // pages still hold references to them ("Cannot add new events after calling
  // close"). Resolving first means the tree shape never changes. Cost is a
  // local SQLite open, small next to the Remote Config fetch just above.
  await sl<SessionReplayService>().start();

  runApp(App());
}

/// Routes every uncaught Dart error to Mixpanel as `App Error`.
///
/// The app had no error observability of any kind before this: no Crashlytics,
/// no global handler, and a great many `catch (_)` blocks that swallow silently
/// — including the Firestore reads behind the Home content lanes, where a
/// failure makes the lane *disappear* rather than show anything. The only
/// errors ever reported were the handful of per-flow failure events.
///
/// Installed first thing in `main()`, before `Firebase.initializeApp`, so a
/// failure during startup is caught too. It cannot report a *native* crash —
/// that needs a crash-reporting SDK — but it covers everything in Dart.
void _installErrorHandlers() {
  final previousOnError = FlutterError.onError;

  FlutterError.onError = (details) {
    // Keep the default behaviour (red screen in debug, console log) — this is
    // an observer, not a replacement.
    previousOnError?.call(details);
    _logAppError(
      details.exception,
      context: details.library ?? 'flutter',
      // `silent` marks errors the framework itself expects to be noisy about
      // but which are not actionable; keep them separable rather than dropped.
      silent: details.silent,
    );
  };

  // Errors outside the framework's own zone: async gaps, platform channels.
  PlatformDispatcher.instance.onError = (error, stack) {
    _logAppError(error, context: 'platform_dispatcher', silent: false);
    // Marking it handled suppresses the console dump too, so print it back —
    // otherwise installing this handler would make debugging *harder*.
    // `presentError` only renders; it does not re-enter `FlutterError.onError`,
    // so there is no recursion and no duplicate event.
    FlutterError.presentError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'platform_dispatcher',
      ),
    );
    // True = handled. Returning false re-raises and terminates the isolate; an
    // analytics handler must never be the thing that kills the app.
    return true;
  };
}

/// Per-session cap on `App Error`. A single failing `build` can throw on every
/// frame, which would otherwise emit thousands of identical events in seconds —
/// enough to swamp the project's event volume and bury everything else.
const int _maxAppErrorsPerSession = 25;
int _appErrorCount = 0;
String? _lastAppErrorSignature;

void _logAppError(
  Object error, {
  required String context,
  required bool silent,
}) {
  // Guarded: this runs inside an error handler, so anything that throws here
  // would recurse. `sl` is not ready until initializeDependencies() completes,
  // which is exactly when a startup error would fire.
  try {
    if (!sl.isRegistered<LogEventUsecase>()) return;

    // Collapse a repeating error to one event. The same exception firing frame
    // after frame is one bug, not N.
    final signature = '$context|${error.runtimeType}|$error';
    if (signature == _lastAppErrorSignature) return;
    _lastAppErrorSignature = signature;

    if (_appErrorCount >= _maxAppErrorsPerSession) return;
    _appErrorCount++;

    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.appError,
      properties: {
        'error_type': error.runtimeType.toString(),
        // Truncated: a Dart error's toString can carry a whole widget tree, and
        // Mixpanel rejects oversized properties.
        'error_message': error.toString().characters.take(500).toString(),
        'context': context,
        'silent': silent,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  } catch (_) {
    // Deliberately empty: nothing useful is left to do from inside the
    // last-resort error path.
  }
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

  /// Resolved in `main()` before `runApp`, so this is its final value — null
  /// when replay is off for this build, non-null when it is on, and never
  /// changing in between. See the note at the `start()` call: a null -> instance
  /// transition here would remount the entire app.
  final MixpanelSessionReplay? _sessionReplay =
      sl<SessionReplayService>().instance;

  /// Start of the current foreground session, for `App Backgrounded`'s duration.
  DateTime _sessionStart = DateTime.now();

  void _logAppOpened(String launchType) {
    final hasOnboarded = sl<SharedPreferences>().getBool('onboarding_completed') ?? false;
    _sessionStart = DateTime.now();
    sl<LogScreenViewUsecase>().resetSessionScreenViews();
    _appErrorCount = 0;
    _lastAppErrorSignature = null;
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

  /// The other end of the session. `App Opened` was the only lifecycle event,
  /// so session length was only ever available through Mixpanel's native
  /// `$ae_session` — which carries no app context and, on the numbers, reaches
  /// fewer users than `App Opened` does.
  void _logAppBackgrounded() {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.appBackgrounded,
      properties: {
        'session_seconds': DateTime.now().difference(_sessionStart).inSeconds,
        'screens_viewed': sl<LogScreenViewUsecase>().screenViewsThisSession,
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
    } else if (state == AppLifecycleState.paused) {
      _logAppBackgrounded();
    }
  }

  String? _syncedLanguage;

  void _syncLocale(String language) {
    if (language == _syncedLanguage) return;
    _syncedLanguage = language;
    sl<UserAnalyticsService>().syncLocale(
      language: language,
      country: WidgetsBinding.instance.platformDispatcher.locale.countryCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MixpanelSessionReplayWidget(
      instance: _sessionReplay,
      child: MultiBlocProvider(
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
          builder: (context, child) {
            // The resolved app locale, not the raw device one — an unsupported
            // device language lands on English here, which is what the user
            // actually reads. Cheap and idempotent; `builder` runs on every
            // rebuild but `syncLocale` is a fire-and-forget property write.
            _syncLocale(Localizations.localeOf(context).languageCode);
            return child ?? const SizedBox.shrink();
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
      ),
    );
  }
}
