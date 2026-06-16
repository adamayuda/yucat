import 'package:algoliasearch/algoliasearch_lite.dart';

class AlgoliaSearchDataSource {
  final SearchClient _client;

  AlgoliaSearchDataSource()
    : _client = SearchClient(
        appId: "GI8VPYUYCP",
        apiKey: "5b6e53aabd413a6325207b6cecb26a2d",
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

  Future<List<Hit>> searchByQuery(String query, {int? hitsPerPage}) async {
    try {
      final request = SearchForHits(
        indexName: "products2",
        query: query,
        hitsPerPage: hitsPerPage,
      );

      final response = await _client.searchIndex(request: request);

      return response.hits;
    } catch (e) {
      throw Exception('Failed to search Algolia: $e');
    }
  }
}
