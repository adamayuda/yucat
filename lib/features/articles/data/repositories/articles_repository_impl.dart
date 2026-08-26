import 'package:yucat/features/articles/data/datasources/article_firestore_datasource.dart';
import 'package:yucat/features/articles/data/mappers/article_document_mapper.dart';
import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/features/articles/domain/repositories/articles_repository.dart';
import 'package:yucat/presentation/utils/supported_language.dart';

class ArticlesRepositoryImpl implements ArticlesRepository {
  final ArticleFirestoreDataSource _dataSource;
  final ArticleDocumentMapper _mapper;

  /// Successful fetches, keyed by resolved language.
  ///
  /// The Home card re-fires its initial event whenever it remounts, so without
  /// this every visit to the Home tab would be a fresh Firestore round-trip.
  /// Only successes are cached — the write happens after the await — so a
  /// failure still re-fetches on the next attempt.
  final Map<String, List<ArticleEntity>> _cache = {};

  ArticlesRepositoryImpl({
    required ArticleFirestoreDataSource dataSource,
    required ArticleDocumentMapper mapper,
  })  : _dataSource = dataSource,
        _mapper = mapper;

  @override
  Future<List<ArticleEntity>> getArticles({String? language}) async {
    final lang = normalizeLanguage(language) ?? kCanonicalLanguage;
    final cached = _cache[lang];
    if (cached != null) return cached;

    final snapshot = await _dataSource.getArticles();
    final articles = snapshot.docs.map((doc) => _mapper(doc, lang)).toList();
    _cache[lang] = articles;
    return articles;
  }
}
