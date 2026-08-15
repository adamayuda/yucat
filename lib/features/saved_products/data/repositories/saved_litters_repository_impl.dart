import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_codec.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_litters_repository.dart';

const _storageKey = 'saved_litters_v1';

class SavedLittersRepositoryImpl implements SavedLittersRepository {
  final SharedPreferences _prefs;

  SavedLittersRepositoryImpl({required SharedPreferences prefs})
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
  Future<bool> isSaved(LitterDisplayModel litter) async {
    final key = litterIdentityKey(litter);
    final all = await getAll();
    return all.any((l) => litterIdentityKey(l) == key);
  }

  @override
  Future<void> save(LitterDisplayModel litter) async {
    final all = await getAll();
    final key = litterIdentityKey(litter);
    if (all.any((l) => litterIdentityKey(l) == key)) return;
    await _persist([litter, ...all]);
  }

  @override
  Future<void> unsave(LitterDisplayModel litter) async {
    final all = await getAll();
    final key = litterIdentityKey(litter);
    await _persist(all.where((l) => litterIdentityKey(l) != key).toList());
  }

  Future<void> _persist(List<LitterDisplayModel> litters) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(litters.map(litterToJson).toList()),
    );
  }
}
