import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class SetUserPropertiesUsecase {
  final AnalyticsRepository repository;

  SetUserPropertiesUsecase({required this.repository});

  Future<void> call(Map<String, dynamic> properties) async {
    return repository.setUserProperties(properties);
  }

  Future<void> setSingle(String propertyName, dynamic value) async {
    return repository.setUserProperty(
      propertyName: propertyName,
      value: value,
    );
  }

  Future<void> increment(String propertyName, double by) async {
    return repository.incrementUserProperty(propertyName, by);
  }
}
