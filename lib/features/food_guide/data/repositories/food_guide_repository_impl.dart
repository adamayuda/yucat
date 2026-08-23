import 'package:yucat/features/food_guide/data/datasources/food_guide_firestore_datasource.dart';
import 'package:yucat/features/food_guide/data/mappers/food_guide_document_mapper.dart';
import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';
import 'package:yucat/features/food_guide/domain/repositories/food_guide_repository.dart';
import 'package:yucat/presentation/utils/supported_language.dart';

class FoodGuideRepositoryImpl implements FoodGuideRepository {
  final FoodGuideFirestoreDataSource _dataSource;
  final FoodGuideDocumentMapper _mapper;

  /// Successful fetches, keyed by resolved language.
  ///
  /// The Home lane re-fires its initial event whenever its section remounts, so
  /// without this every visit to the Home tab would be a fresh Firestore
  /// round-trip. Only successes are cached — the write happens after the await
  /// — so a failure still re-fetches on the next attempt.
  final Map<String, List<FoodGuideEntity>> _cache = {};

  FoodGuideRepositoryImpl({
    required FoodGuideFirestoreDataSource dataSource,
    required FoodGuideDocumentMapper mapper,
  })  : _dataSource = dataSource,
        _mapper = mapper;

  @override
  Future<List<FoodGuideEntity>> getFoodGuide({String? language}) async {
    final lang = normalizeLanguage(language) ?? kCanonicalLanguage;
    final cached = _cache[lang];
    if (cached != null) return cached;

    final snapshot = await _dataSource.getFoodGuide();
    final items = snapshot.docs.map((doc) => _mapper(doc, lang)).toList();
    _cache[lang] = items;
    return items;
  }
}
