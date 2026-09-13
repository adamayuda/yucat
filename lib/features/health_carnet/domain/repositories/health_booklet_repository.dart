import 'package:yucat/features/health_carnet/domain/entities/health_booklet_proposal.dart';

abstract class HealthBookletRepository {
  /// [today] is the device date as YYYY-MM-DD, for resolving two-digit years.
  Future<HealthBookletProposal> readBooklet({
    required String imageBase64,
    required String today,
    String? catName,
  });
}
