import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/litter_detail/presentation/bloc/litter_detail_bloc.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/litter_detail/presentation/widgets/litter_attributes_card.dart';
import 'package:yucat/features/litter_detail/presentation/widgets/litter_cat_notes_card.dart';
import 'package:yucat/features/litter_detail/presentation/widgets/litter_hero_card.dart';
import 'package:yucat/features/litter_detail/presentation/widgets/litter_score_card.dart';
import 'package:yucat/features/product_detail/presentation/widgets/product_detail_skeleton.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';
import 'package:yucat/service_locator.dart';

/// Scan result for a cat litter — the litter twin of `ProductDetailPage`.
@RoutePage()
class LitterDetailPage extends StatefulWidget {
  final LitterDisplayModel? litter;

  const LitterDetailPage({super.key, this.litter});

  @override
  State<LitterDetailPage> createState() => _LitterDetailPageState();
}

class _LitterDetailPageState extends State<LitterDetailPage> {
  late LitterDetailBloc _bloc;
  late GetCatsUsecase _getCatsUsecase;
  late CurrentUserUsecase _currentUserUsecase;
  Future<List<CatEntity>>? _catsFuture;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<LitterDetailBloc>();
    _bloc.add(LitterDetailInitialEvent(litter: widget.litter));
    _getCatsUsecase = sl<GetCatsUsecase>();
    _currentUserUsecase = sl<CurrentUserUsecase>();
    _refreshCats();
  }

  void _refreshCats() {
    final user = _currentUserUsecase();
    if (user != null) {
      setState(() {
        _catsFuture = _getCatsUsecase(userId: user.uid);
      });
    }
  }

  Future<void> _onCreateCat() async {
    await context.router.push(CreateCatRoute());
    _refreshCats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<LitterDetailBloc, LitterDetailState>(
              bloc: _bloc,
              buildWhen: (previous, current) =>
                  previous is! LitterDetailLoadedState ||
                  current is! LitterDetailLoadedState ||
                  previous.isSaved != current.isSaved,
              builder: (context, state) {
                final isSaved =
                    state is LitterDetailLoadedState ? state.isSaved : false;
                return DSAppBar.modal(
                  onBack: () => Navigator.of(context).pop(),
                  actions: [
                    _CircleIconButton(
                      icon: isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      iconColor: isSaved
                          ? DSColors.accentSuccess
                          : DSColors.inkPrimary,
                      onPressed: () => _bloc.add(
                        const LitterDetailToggleSavedEvent(),
                      ),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocBuilder<LitterDetailBloc, LitterDetailState>(
                bloc: _bloc,
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) => switch (state) {
                  LitterDetailLoadedState(:final litter) => _LoadedBody(
                      litter: litter,
                      catsFuture: _catsFuture,
                      onCreateCat: _onCreateCat,
                    ),
                  LitterDetailErrorState() => const _ErrorBody(),
                  _ => const ProductDetailSkeleton(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final LitterDisplayModel litter;
  final Future<List<CatEntity>>? catsFuture;
  final Future<void> Function() onCreateCat;

  const _LoadedBody({
    required this.litter,
    required this.catsFuture,
    required this.onCreateCat,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).padding.bottom + DSDimens.size3xl;
    const hPad = EdgeInsets.symmetric(horizontal: DSDimens.sizeL);

    return ListView(
      padding: EdgeInsets.only(top: DSDimens.sizeXs, bottom: bottomInset),
      children: [
        Padding(padding: hPad, child: LitterHeroCard(litter: litter)),
        const SizedBox(height: DSDimens.sizeL),
        Padding(padding: hPad, child: LitterScoreCard(litter: litter)),
        // With no attributes established there is nothing to put in the card,
        // and the per-cat rules all read attributes — so both are hidden rather
        // than rendered empty.
        if (!litter.dataUnavailable) ...[
          const SizedBox(height: DSDimens.sizeL),
          Padding(padding: hPad, child: LitterAttributesCard(litter: litter)),
          const SizedBox(height: DSDimens.sizeL),
          FutureBuilder<List<CatEntity>>(
            future: catsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: DSDimens.sizeL),
                  child: AppLoadingWidget(),
                );
              }
              return Padding(
                padding: hPad,
                child: LitterCatNotesCard(
                  cats: snapshot.data ?? const [],
                  litter: litter,
                  onCreateCat: () => onCreateCat(),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Builder(
      builder: (context) => DSStateView.error(
        body: l10n.productDetailLoadError,
        ctaLabel: l10n.commonGoBack,
        onCtaPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceCard,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: DSColors.surfaceCard,
          shape: BoxShape.circle,
          boxShadow: DSShadows.e1,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              color: iconColor ?? DSColors.inkPrimary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
