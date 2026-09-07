import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/content_analytics.dart';
import 'package:yucat/features/articles/presentation/bloc/articles_bloc.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/articles/presentation/widgets/article_poster_card.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_section_header.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';
import 'package:yucat/service_locator.dart';

/// "Articles for you" swimlane on Home.
///
/// Full-bleed: the header is inset, the lane is not, so cards scroll under both
/// screen edges. Add it to the Home `ListView` **without** a `Padding` wrapper.
class HomeArticlesSection extends StatefulWidget {
  final VoidCallback onSeeAll;
  final ValueChanged<ArticleDisplayModel> onArticleTap;

  const HomeArticlesSection({
    super.key,
    required this.onSeeAll,
    required this.onArticleTap,
  });

  @override
  State<HomeArticlesSection> createState() => _HomeArticlesSectionState();
}

class _HomeArticlesSectionState extends State<HomeArticlesSection>
    with ContentLaneAnalytics {
  /// How many of the catalogue's articles the lane shows, in authored order.
  ///
  /// ⚠️ `_skip` is 0 and must stay 0 while `HomeNewsCard` is unmounted (YUC-24).
  /// It was 1 only because the card already featured the first article at the
  /// top of the page; with the card parked, skipping would drop article 0 from
  /// Home entirely. Re-mounting the card means restoring it to 1.
  static const int _skip = 0;
  static const int _laneCount = 6;

  late ArticlesBloc _bloc;
  String? _language;

  @override
  void initState() {
    super.initState();
    // A fresh factory instance, like every other Home section. The repository
    // memoizes per language, so this costs no round-trip on top of the news
    // card's fetch.
    _bloc = sl<ArticlesBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (language == _language) return;
    _language = language;
    resetLaneViewed();
    _bloc.add(ArticlesInitialEvent(language: language));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ArticlesBloc, ArticlesState>(
      bloc: _bloc,
      builder: (context, state) {
        // `all`, never `visible` — the list screen's filters must not reach
        // the Home lane.
        final articles = switch (state) {
          ArticlesLoadedState(:final all) =>
            all.skip(_skip).take(_laneCount).toList(),
          _ => const <ArticleDisplayModel>[],
        };
        // Home is a discovery surface: a lane that failed or has nothing to
        // show removes itself, header included.
        if (state is ArticlesErrorState ||
            (state is ArticlesLoadedState && articles.isEmpty)) {
          return const SizedBox.shrink();
        }
        // The count is post-skip, so `Content Lane Viewed` always counts what
        // was actually on offer here rather than the catalogue size.
        reportLaneViewed(
          section: ContentSection.articles,
          itemCount: articles.length,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: DSSectionHeader(
                title: l10n.homeArticlesSectionTitle,
                actionLabel: l10n.homeSeeAll,
                onAction: widget.onSeeAll,
              ),
            ),
            const SizedBox(height: DSDimens.sizeS),
            SizedBox(
              height: ArticlePosterCard.laneHeight,
              child: state is ArticlesLoadedState
                  ? ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSDimens.sizeL,
                      ),
                      itemCount: articles.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: DSDimens.sizeS),
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return ArticlePosterCard(
                          article: article,
                          onTap: () => widget.onArticleTap(article),
                        );
                      },
                    )
                  : const _ArticleLaneShimmer(),
            ),
          ],
        );
      },
    );
  }
}

/// Poster bones while the catalogue loads. The lane's `SizedBox` clips the
/// overhang, so the row can be wider than the screen the way the real lane is.
class _ArticleLaneShimmer extends StatelessWidget {
  const _ArticleLaneShimmer();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: DSDimens.sizeS),
        itemBuilder: (_, __) => const ShimmerBone(
          width: ArticlePosterCard.width,
          height: ArticlePosterCard.laneHeight,
          radius: DSRadii.xl,
        ),
      ),
    );
  }
}
