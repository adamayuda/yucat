import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/search/domain/repositories/recent_searches_repository.dart';

const _storageKey = 'recent_searches_v1';
const _maxEntries = 8;

class RecentSearchesRepositoryImpl implements RecentSearchesRepository {
  final SharedPreferences _prefs;

  RecentSearchesRepositoryImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<List<String>> getRecent() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final all = await getRecent();
    // Most-recent first, case-insensitive dedupe (move-to-front), capped.
    final lower = trimmed.toLowerCase();
    final deduped = all.where((q) => q.toLowerCase() != lower).toList();
    final next = [trimmed, ...deduped];
    if (next.length > _maxEntries) {
      next.removeRange(_maxEntries, next.length);
    }
    await _prefs.setString(_storageKey, jsonEncode(next));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }
}
