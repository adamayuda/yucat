import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads the published recipe catalogue.
///
/// Unlike `CatDataSource` and `BrandDataSource`, which swallow errors and
/// return null, this one **throws**. Those two have repositories that collapse
/// null into an empty list, which for recipes would render the "no recipes
/// match" empty state on a network failure — the wrong affordance. `RecipesBloc`
/// already has a retryable error state wired up, and a throw is what makes it
/// fire.
class RecipeFirestoreDataSource {
  final FirebaseFirestore _firestore;

  RecipeFirestoreDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<QuerySnapshot<Map<String, dynamic>>> getRecipes() async {
    try {
      return await _firestore
          .collection('recipes')
          .where('published', isEqualTo: true)
          .orderBy('order')
          .get();
    } catch (e) {
      throw Exception('Failed to fetch recipes: $e');
    }
  }
}
