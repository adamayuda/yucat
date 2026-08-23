import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads the published food-guide catalogue.
///
/// Like `RecipeFirestoreDataSource` and unlike `CatDataSource`, this **throws**
/// rather than returning null. Collapsing a network failure into an empty list
/// would make the Home lane render its "nothing here" branch, which hides the
/// section silently instead of surfacing a real error.
///
/// ⚠️ The `published == true` + `orderBy('order')` pair needs a composite index
/// on `foodGuide` (`published ASC, order ASC`) — an equality filter plus an
/// orderBy on a different field is never covered by the single-field automatic
/// indexes. Indexes for this project are managed in the console, not this repo.
class FoodGuideFirestoreDataSource {
  final FirebaseFirestore _firestore;

  FoodGuideFirestoreDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<QuerySnapshot<Map<String, dynamic>>> getFoodGuide() async {
    try {
      return await _firestore
          .collection('foodGuide')
          .where('published', isEqualTo: true)
          .orderBy('order')
          .get();
    } catch (e) {
      throw Exception('Failed to fetch food guide: $e');
    }
  }
}
