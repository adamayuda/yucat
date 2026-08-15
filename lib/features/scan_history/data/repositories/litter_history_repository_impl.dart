import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_codec.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/scan_history/domain/repositories/litter_history_repository.dart';

const _storageKey = 'litter_history_v1';
const _maxEntries = 50;

class LitterHistoryRepositoryImpl implements LitterHistoryRepository {
  final SharedPreferences _prefs;

  LitterHistoryRepositoryImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<List<LitterDisplayModel>> getAll() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(litterFromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> add(LitterDisplayModel litter) async {
    final all = await getAll();
    final key = litterIdentityKey(litter);
    final deduped = all.where((l) => litterIdentityKey(l) != key).toList();
    final next = [litter, ...deduped];
    if (next.length > _maxEntries) {
      next.removeRange(_maxEntries, next.length);
    }
    await _persist(next);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }

  Future<void> _persist(List<LitterDisplayModel> litters) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(litters.map(litterToJson).toList()),
    );
  }
}
