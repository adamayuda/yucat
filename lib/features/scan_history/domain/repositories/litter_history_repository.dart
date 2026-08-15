import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';

/// Scanned litters, most recent first. Like the food history this is a list of
/// **distinct litters, not a scan log**: rescanning the same bag replaces the
/// prior entry rather than appending, and there is no timestamp field.
abstract class LitterHistoryRepository {
  Future<List<LitterDisplayModel>> getAll();
  Future<void> add(LitterDisplayModel litter);
  Future<void> clear();
}
