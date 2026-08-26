import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/articles/presentation/bloc/articles_bloc.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/articles/presentation/widgets/article_category_strip.dart';
import 'package:yucat/features/articles/presentation/widgets/article_list_row.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_text_field.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_circle_icon_button.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/components/skeletons/product_list_skeleton.dart';
import 'package:yucat/service_locator.dart';

/// Every article, searchable and category-filtered. Reached from the Home
/// lane's "See all".
@RoutePage()
class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
    DSDimens.sizeL,
    0,
    DSDimens.sizeL,
    DSDimens.size4xl,
  );

  late ArticlesBloc _bloc;
  String? _language;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // A fresh factory instance — `ArticlesBloc` is not in main.dart's
    // MultiBlocProvider. The repository memoizes per language, so arriving
    // here from Home costs no round-trip and the list paints at once.
    _bloc = sl<ArticlesBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // App language, not the device locale — an unsupported device language
    // correctly asks for English. Read here rather than in initState because
    // Localizations needs a settled context.
    final language = Localizations.localeOf(context).languageCode;
    if (language == _language) return;
    _language = language;
    _bloc.add(ArticlesInitialEvent(language: language));
  }

  @override
  void dispose() {
    // Both are ours: the controller and, unlike `RecipesPage`, the bloc.
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _bloc.add(ArticlesQueryChanged(query: value));
  }

  void _onClear() {
    _searchController.clear();
    _bloc.add(const ArticlesQueryChanged(query: ''));
  }

  void _openArticle(ArticleDisplayModel article) {
    context.router.push(ArticleDetailRoute(article: article));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DSColors.pageBackground,
      body: SafeArea(
        child: BlocBuilder<ArticlesBloc, ArticlesState>(
          bloc: _bloc,
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Not DSAppBar.modal: that renders a bare IconButton, and this
                // screen's back control is the white disc the detail screens
                // use. The title sits below it, inline with the content.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    DSDimens.sizeXxs,
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DSCircleIconButton(
                      icon: Icons.chevron_left,
                      size: 40,
                      onPressed: () => context.router.maybePop(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    0,
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                  ),
                  child: Text(
                    l10n.articlesTitle,
                    style: DSTextStyles.displayLg,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    0,
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                  ),
                  child: SearchTextField(
                    controller: _searchController,
                    hintText: l10n.articlesSearchHint,
                    onChanged: _onQueryChanged,
                    onClear: _onClear,
                  ),
                ),
                ArticleCategoryStrip(
                  selected: state is ArticlesLoadedState
                      ? state.selectedCategory
                      : null,
                  onSelected: (category) => _bloc.add(
                    ArticlesCategorySelected(category: category),
                  ),
                ),
                const SizedBox(height: DSDimens.sizeS),
                Expanded(child: _buildBody(state, l10n)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(ArticlesState state, AppLocalizations l10n) {
    return switch (state) {
      ArticlesLoadingState() =>
        const ProductListSkeleton(padding: _listPadding),
      // ⚠️ Unlike Home's card and lane, which remove themselves on failure,
      // this screen surfaces the error: a section inside a discovery feed can
      // disappear gracefully, but a screen the user navigated to on purpose
      // must not render blank.
      ArticlesErrorState() => DSStateView.error(
          body: l10n.articlesErrorBody,
          onCtaPressed: () =>
              _bloc.add(ArticlesInitialEvent(language: _language)),
        ),
      ArticlesLoadedState(:final visible) => visible.isEmpty
          ? DSStateView.empty(
              mascotAsset: 'assets/images/cat-thinking.svg',
              tint: DSColors.tintMint,
              headline: l10n.articlesEmptyHeadline,
              body: l10n.articlesEmptyBody,
            )
          : ListView.separated(
              padding: _listPadding,
              itemCount: visible.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DSDimens.sizeXs),
              itemBuilder: (context, index) {
                final article = visible[index];
                return ArticleListRow(
                  article: article,
                  onTap: () => _openArticle(article),
                );
              },
            ),
    };
  }
}
