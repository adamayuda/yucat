import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/content_analytics.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/articles/presentation/widgets/article_meta.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_circle_icon_button.dart';

/// One article: hero, category pill, headline, read time and body paragraphs.
///
/// Bloc-free — like `RecipeDetailPage`, everything rendered here arrives on the
/// model the route carries, so there is no async work to orchestrate. It is
/// stateful only to measure the read: a dwell timer and the furthest scroll
/// reached, reported once on dispose as `Article Read`. Nothing in that state
/// touches the build output, so the screen still renders purely from [article].
@RoutePage()
class ArticleDetailPage extends StatefulWidget {
  final ArticleDisplayModel article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  static const double _heroHeight = 260;

  final ScrollController _scrollController = ScrollController();
  final DateTime _openedAt = DateTime.now();

  /// Furthest point reached, 0.0–1.0. Never decreases: scrolling back up does
  /// not un-read the paragraphs above.
  double _maxScrollFraction = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // A short article that fits the viewport can never fire a scroll callback,
    // and would otherwise report 0% — indistinguishable from a bounce. Resolve
    // it once the list has been laid out and its extent is known.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        _maxScrollFraction = 1;
      }
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    final max = position.maxScrollExtent;
    final fraction =
        max <= 0 ? 1.0 : (position.pixels / max).clamp(0.0, 1.0);
    if (fraction > _maxScrollFraction) _maxScrollFraction = fraction;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    logArticleRead(
      widget.article,
      seconds: DateTime.now().difference(_openedAt).inSeconds,
      scrollPct: (_maxScrollFraction * 100).round(),
    );
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: DSColors.pageBackground,
      // No top SafeArea: the hero deliberately bleeds under the status bar, and
      // the back button is inset by the padding instead.
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + DSDimens.size4xl,
            ),
            children: [
              _Hero(imageUrl: article.imageUrl, height: _heroHeight),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSDimens.sizeL,
                  DSDimens.sizeL,
                  DSDimens.sizeL,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArticleCategoryPill(category: article.category),
                    const SizedBox(height: DSDimens.sizeS),
                    Text(article.title, style: DSTextStyles.displayLg),
                    const SizedBox(height: DSDimens.sizeXxs),
                    Text(
                      l10n.articleDetailReadTime(article.readMinutes),
                      style: DSTextStyles.bodyLg.copyWith(
                        color: DSColors.inkTertiary,
                      ),
                    ),
                    const SizedBox(height: DSDimens.sizeL),
                    // Paragraphs, not one blob: `body` is authored as a list so
                    // the spacing between them is layout rather than whitespace
                    // the translator could disturb.
                    for (var i = 0; i < article.body.length; i++) ...[
                      if (i > 0) const SizedBox(height: DSDimens.sizeS),
                      Text(
                        article.body[i],
                        style: DSTextStyles.bodyLg.copyWith(
                          color: DSColors.inkSecondary,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: topInset + DSDimens.sizeXxs,
            left: DSDimens.sizeL,
            child: DSCircleIconButton(
              icon: Icons.chevron_left,
              size: 40,
              onPressed: () => context.router.maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String? imageUrl;
  final double height;

  const _Hero({required this.imageUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    // Null-check first so an article with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      height: height,
      width: double.infinity,
      color: DSColors.tintLavender,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              height: height,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  const ArticleImagePlaceholder(size: 56),
            )
          : const ArticleImagePlaceholder(size: 56),
    );
  }
}
