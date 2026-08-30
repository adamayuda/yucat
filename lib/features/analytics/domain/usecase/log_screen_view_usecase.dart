import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogScreenViewUsecase {
  final AnalyticsRepository repository;

  LogScreenViewUsecase({required this.repository});

  int _screenViewsThisSession = 0;

  /// Screen views since the last foreground, read by `App Backgrounded` as a
  /// depth measure for the session.
  ///
  /// Counted here rather than in `AnalyticsRouteObserver` because the observer
  /// is not the only source: `bottom_nav_bar.dart` and `home_page.dart` emit
  /// screen views by hand for tab changes, which push no route. This usecase is
  /// the one point every screen view passes through.
  int get screenViewsThisSession => _screenViewsThisSession;

  /// Call when a new foreground session begins.
  void resetSessionScreenViews() => _screenViewsThisSession = 0;

  Future<void> call({
    required String screenName,
    int? index,
    String? name,
  }) async {
    _screenViewsThisSession++;
    return repository.trackScreenView(
      screenName: screenName,
      index: index,
      name: name,
    );
  }
}
