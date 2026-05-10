import 'package:algoliasearch/algoliasearch_lite.dart';

class AlgoliaSearchDataSource {
  final SearchClient _client;

  AlgoliaSearchDataSource()
    : _client = SearchClient(
        appId: "GI8VPYUYCP",
        apiKey: "3c0ee15455a00d73d8325e1985556008",
      );

  Future<List<Hit>> searchByBrand(String brandName) async {
    try {
      final request = SearchForHits(
        indexName: "products2",
        query: '',
        facetFilters: ["brand:$brandName"],
      );

      final response = await _client.searchIndex(request: request);

      return response.hits;
    } catch (e) {
      throw Exception('Failed to search Algolia: $e');
    }
  }

  Future<List<Hit>> searchByQuery(String query) async {
    try {
      final request = SearchForHits(indexName: "products2", query: query);

      final response = await _client.searchIndex(request: request);

      return response.hits;
    } catch (e) {
      throw Exception('Failed to search Algolia: $e');
    }
  }
}
