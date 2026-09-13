import 'package:yucat/features/health_carnet/data/datasources/health_booklet_datasource.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_booklet_proposal.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/repositories/health_booklet_repository.dart';

class HealthBookletRepositoryImpl implements HealthBookletRepository {
  final HealthBookletDataSource _dataSource;

  HealthBookletRepositoryImpl({required HealthBookletDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<HealthBookletProposal> readBooklet({
    required String imageBase64,
    required String today,
    String? catName,
  }) async {
    final data = await _dataSource.readBooklet(
      imageBase64: imageBase64,
      today: today,
      catName: catName,
    );
    if (data == null) {
      return const HealthBookletProposal(
        outcome: HealthBookletOutcome.unreadable,
        records: [],
      );
    }
    final raw = data['records'];
    final records = <HealthBookletRecord>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final date = DateTime.tryParse(item['performed_at'] as String? ?? '');
        if (date == null) continue; // the server already filters; belt and braces
        final protocolId = item['protocol_id'] as String?;
        records.add(HealthBookletRecord(
          protocolId: protocolId == null || protocolId.isEmpty ? null : protocolId,
          title: (item['title'] as String? ?? '').trim(),
          category: HealthCategory.fromWire(item['category'] as String?),
          performedAt: date,
          intervalDays: (item['interval_days'] as num?)?.toInt(),
          vet: _emptyToNull(item['vet'] as String?),
          clinic: _emptyToNull(item['clinic'] as String?),
          confidence:
              HealthBookletConfidence.fromWire(item['confidence'] as String?),
        ));
      }
    }
    return HealthBookletProposal(
      outcome: HealthBookletOutcome.fromWire(data['outcome'] as String?),
      records: records,
    );
  }

  static String? _emptyToNull(String? v) {
    final t = v?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
