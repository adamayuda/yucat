import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads the published article catalogue.
///
/// Like its recipe and food-guide siblings and unlike `CatDataSource`, this
/// **throws** rather than returning null. Collapsing a network failure into an
/// empty list would make the Home card render its "nothing here" branch, which
/// hides the card silently instead of surfacing a real error to the list screen.
///
/// ⚠️ The `published == true` + `orderBy('order')` pair needs a composite index
/// on `articles` (`published ASC, order ASC`) — an equality filter plus an
/// orderBy on a different field is never covered by the single-field automatic
/// indexes. Indexes for this project are managed in the console, not this repo.
class ArticleFirestoreDataSource {
  final FirebaseFirestore _firestore;

  ArticleFirestoreDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<QuerySnapshot<Map<String, dynamic>>> getArticles() async {
    try {
      return await _firestore
          .collection('articles')
          .where('published', isEqualTo: true)
          .orderBy('order')
          .get();
    } catch (e) {
      throw Exception('Failed to fetch articles: $e');
    }
  }
}
