// import 'package:algoliasearch/algoliasearch.dart';
// import 'package:yucat/features/product_detail/presentation/models/product_model.dart';

// class AlgoliaSearchDataSource {
//   final SearchClient _client;
//   final String _indexName;

//   AlgoliaSearchDataSource({
//     required String applicationId,
//     required String apiKey,
//     required String indexName,
//   }) : _client = SearchClient(applicationId: applicationId, apiKey: apiKey),
//        _indexName = indexName;

//   Future<List<ProductModel>> searchByBarcode(String barcode) async {
//     try {
//       final index = _client.initIndex(_indexName);
//       final response = await index.search(
//         Query(query: barcode, filters: 'barcode:"$barcode"'),
//       );

//       final hits = response.hits;
//       return hits.map((hit) => _mapHitToProduct(hit)).toList();
//     } catch (e) {
//       throw Exception('Failed to search Algolia: $e');
//     }
//   }

//   Future<List<ProductModel>> searchByQuery(String query) async {
//     try {
//       final index = _client.initIndex(_indexName);
//       final response = await index.search(Query(query: query));

//       final hits = response.hits;
//       return hits.map((hit) => _mapHitToProduct(hit)).toList();
//     } catch (e) {
//       throw Exception('Failed to search Algolia: $e');
//     }
//   }

//   ProductModel _mapHitToProduct(Map<String, dynamic> hit) {
//     // Map Algolia hit to ProductModel
//     // Adjust these mappings based on your Algolia index structure
//     final data = hit['_highlightResult'] ?? hit;

//     return ProductModel(
//       name: data['name'] ?? hit['name'] ?? 'Unknown Product',
//       brand: data['brand'] ?? hit['brand'] ?? 'Unknown Brand',
//       score: _parseInt(hit['score'], 17),
//       maxScore: _parseInt(hit['maxScore'], 100),
//       ratingText: hit['ratingText'] ?? 'Unknown',
//       ratingColor: _parseRatingColor(hit['ratingColor']),
//       imageUrl: hit['imageUrl'],
//       calories: _parseInt(hit['calories'], 500),
//       proteins: _parseDouble(hit['proteins'], 30.0),
//       fats: _parseDouble(hit['fats'], 120.0),
//       carbs: _parseDouble(hit['carbs'], 60.0),
//       healthScore: _parseInt(hit['healthScore'], 8),
//       additives: _parseInt(hit['additives'], 3),
//       additivesRisk: hit['additivesRisk'] ?? 'With limited risk',
//       saturatedFat: _parseDouble(hit['saturatedFat'], 17.3),
//       saturatedFatStatus: hit['saturatedFatStatus'] ?? 'Too fatty',
//       salt: _parseDouble(hit['salt'], 0.27),
//       saltStatus: hit['saltStatus'] ?? 'Low salt',
//       protein: _parseDouble(hit['protein'], 6.4),
//     );
//   }

//   int _parseInt(dynamic value, int defaultValue) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? defaultValue;
//     return defaultValue;
//   }

//   double _parseDouble(dynamic value, double defaultValue) {
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? defaultValue;
//     return defaultValue;
//   }

//   ProductRatingColor _parseRatingColor(dynamic value) {
//     if (value is String) {
//       switch (value.toLowerCase()) {
//         case 'red':
//           return ProductRatingColor.red;
//         case 'yellow':
//         case 'amber':
//           return ProductRatingColor.yellow;
//         case 'green':
//           return ProductRatingColor.green;
//       }
//     }
//     return ProductRatingColor.red;
//   }
// }

