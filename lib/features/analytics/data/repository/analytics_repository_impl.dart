import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class AnalyticsRepositoryImpl extends AnalyticsRepository {
  final Mixpanel _mixpanel;

  AnalyticsRepositoryImpl({required Mixpanel mixpanel}) : _mixpanel = mixpanel;

  @override
  void trackScreenView({required String screenName, int? index, String? name}) {
    _mixpanel.track(
      'Screen View',
      properties: {'screen_name': screenName, 'index': index, 'name': name},
    );
  }
}
