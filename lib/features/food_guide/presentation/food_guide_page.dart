import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/presentation/bloc/food_guide_bloc.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/food_guide/presentation/widgets/food_guide_list_row.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_circle_icon_button.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/service_locator.dart';

/// Every food-guide category, reached from the Home lane's "See all".
@RoutePage()
class FoodGuidePage extends StatefulWidget {
  const FoodGuidePage({super.key});

  @override
  State<FoodGuidePage> createState() => _FoodGuidePageState();
}

class _FoodGuidePageState extends State<FoodGuidePage> {
  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
    DSDimens.sizeL,
    DSDimens.sizeS,
    DSDimens.sizeL,
    DSDimens.size4xl,
  );

  late FoodGuideBloc _bloc;
  String? _language;

  @override
  void initState() {
    super.initState();
    // A fresh factory instance, like Home's FoodGuideSection — the bloc is not
    // in main.dart's MultiBlocProvider. The repository memoizes per language,
    // so arriving here from Home costs no round-trip and the list paints at
    // once.
    _bloc = sl<FoodGuideBloc>();
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
    _bloc.add(FoodGuideInitialEvent(language: language));
  }

  @override
  void dispose() {
    // This instance is ours, so closing it is required.
    _bloc.close();
    super.dispose();
  }

  void _openItem(FoodGuideDisplayModel item) {
    context.router.push(FoodGuideDetailRoute(item: item));
  }

  void _retry() {
    _bloc.add(FoodGuideInitialEvent(language: _language));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DSColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Not DSAppBar.modal: that renders a bare IconButton, and this
            // screen's back control is the white disc used by Recipe and Food
            // Guide detail. The title lives in the list below, not the bar.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSDimens.sizeL,
                DSDimens.sizeXxs,
                DSDimens.sizeL,
                0,
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
            Expanded(
              child: BlocBuilder<FoodGuideBloc, FoodGuideState>(
                bloc: _bloc,
                builder: (context, state) => switch (state) {
                  // ⚠️ Unlike Home's lane, which removes itself on failure,
                  // this screen surfaces the error: a section inside a
                  // discovery feed can disappear gracefully, but a screen the
                  // user navigated to on purpose must not render blank.
                  FoodGuideErrorState() => DSStateView.error(
                      body: l10n.foodGuideErrorBody,
                      onCtaPressed: _retry,
                    ),
                  FoodGuideLoadingState() => const _FoodGuideListSkeleton(
                      padding: _listPadding,
                    ),
                  FoodGuideLoadedState(:final items) => items.isEmpty
                      ? DSStateView.empty(
                          mascotAsset: 'assets/images/cat-thinking.svg',
                          body: l10n.foodGuideEmptyBody,
                        )
                      : ListView(
                          padding: _listPadding,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: DSDimens.sizeS,
                              ),
                              child: Text(
                                l10n.foodGuideListTitle,
                                style: DSTextStyles.displayLg,
                              ),
                            ),
                            for (final item in items) ...[
                              FoodGuideListRow(
                                item: item,
                                onTap: () => _openItem(item),
                              ),
                              const SizedBox(height: DSDimens.sizeS),
                            ],
                          ],
                        ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row bones matching `FoodGuideListRow`'s height, plus the title.
class _FoodGuideListSkeleton extends StatelessWidget {
  final EdgeInsets padding;

  const _FoodGuideListSkeleton({required this.padding});

  @override
  Widget build(BuildContext context) {
    return DeferredSkeleton(
      child: DSShimmer(
        child: ListView(
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: DSDimens.sizeS),
              child: ShimmerBone(width: 220, height: 34, radius: DSRadii.sm),
            ),
            for (var i = 0; i < 6; i++) ...[
              const ShimmerBone(height: 96, radius: DSRadii.xl),
              const SizedBox(height: DSDimens.sizeS),
            ],
          ],
        ),
      ),
    );
  }
}
