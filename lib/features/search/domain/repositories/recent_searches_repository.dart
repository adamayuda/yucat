abstract class RecentSearchesRepository {
  Future<List<String>> getRecent();
  Future<void> add(String query);
  Future<void> clear();
}
