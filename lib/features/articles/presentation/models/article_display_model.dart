import 'package:equatable/equatable.dart';
import 'package:yucat/features/articles/domain/entities/article_entity.dart';

/// What the Home card, the (future) list row and the detail screen render.
///
/// Extends [Equatable] because it will travel as an auto_route argument once
/// the detail screen lands; `body` is a `List<String>`, whose elements are
/// value types, so no hand-rolled `==` is needed.
class ArticleDisplayModel extends Equatable {
  final String id;
  final String title;
  final String excerpt;
  final List<String> body;
  final ArticleCategory category;
  final int readMinutes;
  final String? imageUrl;

  const ArticleDisplayModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.category,
    required this.readMinutes,
    this.body = const [],
    this.imageUrl,
  });

  /// Lower-cased title + excerpt, so the list's filter doesn't re-derive the
  /// casing rules at each call site. Deliberately excludes [body]: matching on
  /// a word buried in paragraph four returns results whose relevance the row
  /// can't show.
  String get searchHaystack => '$title $excerpt'.toLowerCase();

  @override
  List<Object?> get props => [
        id,
        title,
        excerpt,
        body,
        category,
        readMinutes,
        imageUrl,
      ];
}
