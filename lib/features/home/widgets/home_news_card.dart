import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/content_analytics.dart';
import 'package:yucat/features/articles/presentation/bloc/articles_bloc.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';
import 'package:yucat/service_locator.dart';

/// The daily "good to know" card on Home: a blue eyebrow, a headline, a short
/// excerpt, a square thumbnail and a "Learn more" link.
///
/// Shows the **first** article in authored order — which article that is comes
/// from the `order` field in the seed data, not from anything computed here.
class HomeNewsCard extends StatefulWidget {
  final ValueChanged<ArticleDisplayModel> onArticleTap;

  const HomeNewsCard({super.key, required this.onArticleTap});

  @override
  State<HomeNewsCard> createState() => _HomeNewsCardState();
}

class _HomeNewsCardState extends State<HomeNewsCard>
    with ContentLaneAnalytics {
  late ArticlesBloc _bloc;
  String? _language;

  @override
  void initState() {
    super.initState();
    // A fresh factory instance — `ArticlesBloc` is deliberately absent from
    // main.dart's MultiBlocProvider, so each consumer owns one. The repository
    // memoizes per language, so this and `HomeArticlesSection` below share one
    // Firestore round-trip between them.
    _bloc = sl<ArticlesBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // App language (not the device locale) — the locale the app actually
    // resolved to, so an unsupported device language correctly asks for
    // English. Read here rather than in initState because Localizations needs
    // a settled context.
    final language = Localizations.localeOf(context).languageCode;
    if (language == _language) return;
    _language = language;
    resetLaneViewed();
    _bloc.add(ArticlesInitialEvent(language: language));
  }

  @override
  void dispose() {
    // This instance is ours, so closing it is required.
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticlesBloc, ArticlesState>(
      bloc: _bloc,
      builder: (context, state) {
        // Home is a discovery surface: a card that failed or has nothing to
        // show removes itself rather than shouting.
        if (state is ArticlesErrorState) return const SizedBox.shrink();
        if (state is ArticlesLoadedState) {
          // `all`, never `visible` — the list screen's filters must not reach
          // the Home card.
          if (state.all.isEmpty) return const SizedBox.shrink();
          final article = state.all.first;
          // Always 1 — the card features a single article. It is tracked as its
          // own section anyway, because it converts separately from the lane
          // (`source = home_news_card`) and needs its own denominator.
          reportLaneViewed(section: ContentSection.newsCard, itemCount: 1);
          return _NewsCardBody(
            article: article,
            onTap: () => widget.onArticleTap(article),
          );
        }
        return const _NewsCardShimmer();
      },
    );
  }
}

class _NewsCardBody extends StatelessWidget {
  final ArticleDisplayModel article;
  final VoidCallback onTap;

  const _NewsCardBody({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSDimens.sizeXs,
              DSDimens.sizeXs,
              0,
              0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ExcludeSemantics(
                            child: SvgPicture.asset(
                              'assets/images/star-sharp.svg',
                              width: 13,
                              colorFilter: const ColorFilter.mode(
                                DSColors.accentInfo,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: DSDimens.sizeXxs),
                          Flexible(
                            child: Text(
                              l10n.homeNewsEyebrow.toUpperCase(),
                              style: DSTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: DSColors.accentInfo,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DSDimens.sizeXs),
                      Text(
                        article.title,
                        style: DSTextStyles.headlineMd,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DSDimens.sizeXxs),
                      Text(
                        article.excerpt,
                        style: DSTextStyles.bodyLg.copyWith(
                          color: DSColors.inkSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSDimens.sizeS),
                _NewsThumb(imageUrl: article.imageUrl),
              ],
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          DSTextLink(
            label: l10n.homeNewsLearnMore,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _NewsThumb extends StatelessWidget {
  final String? imageUrl;

  const _NewsThumb({required this.imageUrl});

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    // Check for a URL first so an article with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: DSColors.tintLavender,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: _size,
              height: _size,
              errorBuilder: (_, __, ___) => const _ThumbPlaceholder(),
            )
          : const _ThumbPlaceholder(),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Text('🐱', style: TextStyle(fontSize: 40)),
    );
  }
}

/// Card silhouette while the catalogue loads — the same shape as
/// `home_skeleton.dart`'s `_NewsCardBone`, which covers the earlier window
/// before `HomeDashboardPage` mounts at all.
class _NewsCardShimmer extends StatelessWidget {
  const _NewsCardShimmer();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: DSShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FractionallySizedBox(
                    widthFactor: 0.55,
                    child: ShimmerBone(height: 12, radius: DSRadii.sm),
                  ),
                  SizedBox(height: DSDimens.sizeS),
                  ShimmerBone(height: 20, radius: DSRadii.sm),
                  SizedBox(height: DSDimens.sizeXxs),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: ShimmerBone(height: 20, radius: DSRadii.sm),
                  ),
                  SizedBox(height: DSDimens.sizeXs),
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: ShimmerBone(height: 13, radius: DSRadii.sm),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSDimens.sizeS),
            const ShimmerBone(width: 88, height: 88, radius: DSRadii.lg),
          ],
        ),
      ),
    );
  }
}
