import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';

/// Bookmarked litters. A separate store from [SavedProductsRepository] rather
/// than a discriminated list in the same one: the two models share no fields
/// beyond name/brand/score, and a single heterogeneous list would push a
/// `switch` into every consumer of saved products.
abstract class SavedLittersRepository {
  Future<List<LitterDisplayModel>> getAll();
  Future<bool> isSaved(LitterDisplayModel litter);
  Future<void> save(LitterDisplayModel litter);
  Future<void> unsave(LitterDisplayModel litter);
}
