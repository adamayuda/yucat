import 'package:yucat/features/recipes/data/datasources/recipe_firestore_datasource.dart';
import 'package:yucat/features/recipes/data/mappers/recipe_document_mapper.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:yucat/presentation/utils/supported_language.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipeFirestoreDataSource _dataSource;
  final RecipeDocumentMapper _mapper;

  /// Successful fetches, keyed by resolved language.
  ///
  /// `RecipesPage` fires its initial event from `initState`, so without this
  /// every visit to the Recipes tab would be a fresh Firestore round-trip. Only
  /// successes are cached, so the error state's retry still re-fetches.
  final Map<String, List<RecipeEntity>> _cache = {};

  RecipesRepositoryImpl({
    required RecipeFirestoreDataSource dataSource,
    required RecipeDocumentMapper mapper,
  })  : _dataSource = dataSource,
        _mapper = mapper;

  @override
  Future<List<RecipeEntity>> getRecipes({String? language}) async {
    final lang = normalizeLanguage(language) ?? kCanonicalLanguage;
    final cached = _cache[lang];
    if (cached != null) return cached;

    final snapshot = await _dataSource.getRecipes();
    final recipes =
        snapshot.docs.map((doc) => _mapper(doc, lang)).toList();
    _cache[lang] = recipes;
    return recipes;
  }
}
