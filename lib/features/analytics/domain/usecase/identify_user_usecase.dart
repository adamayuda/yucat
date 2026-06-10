import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

/// Binds analytics events to a stable People profile using the anonymous
/// Firebase UID. Call once per session, as soon as auth resolves.
class IdentifyUserUsecase {
  final AnalyticsRepository repository;

  IdentifyUserUsecase({required this.repository});

  Future<void> call(String distinctId) async {
    return repository.identify(distinctId);
  }
}
