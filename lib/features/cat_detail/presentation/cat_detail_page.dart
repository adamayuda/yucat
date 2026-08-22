import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/presentation/utils/cat_diet_recommendations.dart';
import 'package:yucat/features/cat/presentation/widgets/dietary_recommendations_card.dart';
import 'package:yucat/features/cat/presentation/widgets/recommended_products_section.dart';
import 'package:yucat/features/cat_detail/presentation/bloc/cat_detail_bloc.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_detail_skeleton.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_hero_section.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_stat_tile.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_confirm_dialog.dart';

@RoutePage()
class CatDetailPage extends StatefulWidget {
  final CatModel cat;

  const CatDetailPage({super.key, required this.cat});

  @override
  State<CatDetailPage> createState() => _CatDetailPageState();
}

class _CatDetailPageState extends State<CatDetailPage> {
  late CatDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatDetailBloc>();
    _bloc.add(CatDetailInitialEvent(cat: widget.cat));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatDetailBloc, CatDetailState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is CatDetailDeletedState) {
          Navigator.of(context).pop(true);
        } else if (state is CatDetailErrorState) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.catDetailDeleteError),
              backgroundColor: DSColors.accentDanger,
            ),
          );
        } else if (state is CatDetailNavigateToEditState) {
          context.router.push(CreateCatRoute(cat: state.cat));
        }
      },
      builder: (context, state) {
        if (state is CatDetailLoadingState) {
          return const Scaffold(
            backgroundColor: DSColors.pageBackground,
            body: SafeArea(child: CatDetailSkeleton()),
          );
        }

        final cat = state is CatDetailLoadedState ? state.cat : widget.cat;

        return Scaffold(
          backgroundColor: DSColors.pageBackground,
          body: SafeArea(
            child: Column(
              children: [
                DSAppBar.modal(
                  onBack: () => Navigator.of(context).pop(),
                  actions: [
                    IconButton(
                      onPressed: () => _bloc.add(CatDetailEditEvent(cat: cat)),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: DSColors.inkPrimary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      DSDimens.sizeL,
                      DSDimens.sizeS,
                      DSDimens.sizeL,
                      DSDimens.size4xl,
                    ),
                    children: [
                      const SizedBox(height: DSDimens.sizeS),
                      CatHeroSection(cat: cat),
                      const SizedBox(height: DSDimens.size3xl),
                      _ProfileCompletionCard(cat: cat),
                      const SizedBox(height: DSDimens.sizeS),
                      _DetailsCard(cat: cat),
                      if (cat.healthConditions != null &&
                          cat.healthConditions!.isNotEmpty) ...[
                        const SizedBox(height: DSDimens.sizeS),
                        _ConditionsCard(
                          conditions: cat.healthConditions!,
                        ),
                      ],
                      const SizedBox(height: DSDimens.sizeS),
                      _DietaryTipsCard(cat: cat),
                      const SizedBox(height: DSDimens.sizeL),
                      _RecommendedProductsCard(cat: cat),
                      const SizedBox(height: DSDimens.size3xl),
                      _DeleteLink(
                        onTap: () async {
                          final confirmed =
                              await _showDeleteConfirmationDialog(
                            context,
                            cat.name,
                          );
                          if (confirmed == true && cat.id != null) {
                            _bloc.add(CatDetailDeleteEvent(catId: cat.id!));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    String catName,
  ) {
    final l10n = AppLocalizations.of(context);
    return showDSConfirmDialog(
      context,
      title: l10n.catDetailDeleteTitle(catName),
      body: l10n.catDetailDeleteBody,
      confirmLabel: l10n.catDetailDeleteConfirm,
      cancelLabel: l10n.catDetailDeleteCancel,
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final CatModel cat;

  const _ProfileCompletionCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fields = [
      cat.breed,
      cat.age,
      cat.gender,
      cat.activityLevel,
      cat.coatType,
      cat.neuteredStatus ?? (cat.neutered ? 'neutered' : null),
      cat.healthConditions?.isNotEmpty == true ? 'has_conditions' : null,
      cat.profileImageUrl,
    ];
    final filled = fields.where((f) => f != null).length;
    final percent = (filled / fields.length * 100).round();
    final isComplete = percent == 100;

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.catDetailProfileCompletion,
                style: DSTextStyles.titleMd,
              ),
              Text(
                '$percent%',
                style: DSTextStyles.titleMd.copyWith(
                  color: isComplete
                      ? DSColors.accentSuccess
                      : DSColors.inkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeXs),
          ClipRRect(
            borderRadius: BorderRadius.circular(DSRadii.pill),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: DSColors.surfaceCardDim),
                  FractionallySizedBox(
                    widthFactor: (percent / 100).clamp(0, 1),
                    child: AnimatedContainer(
                      duration: DSMotion.durMed,
                      curve: DSMotion.curveStandard,
                      color: DSColors.accentSuccess,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final CatModel cat;

  const _DetailsCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notSet = l10n.catDetailNotSet;
    final tiles = <_TileSpec>[
      _TileSpec(
        l10n.catDetailBreedLabel,
        cat.breed ?? notSet,
        iconAsset: 'catwalk.svg',
      ),
      _TileSpec(
        l10n.catDetailAgeLabel,
        cat.age != null ? catFormatAge(cat.age!, l10n) : notSet,
        iconAsset: 'Cake.svg',
      ),
      _TileSpec(
        l10n.catDetailGenderLabel,
        cat.gender != null ? catFormatGender(cat.gender!, l10n) : notSet,
        icon: cat.gender?.toLowerCase() == 'male'
            ? Icons.male_rounded
            : cat.gender?.toLowerCase() == 'female'
                ? Icons.female_rounded
                : Icons.transgender_rounded,
      ),
      _TileSpec(
        l10n.catDetailCoatLabel,
        cat.coatType != null ? catFormatCoatType(cat.coatType!, l10n) : notSet,
        iconAsset: 'Coat.svg',
      ),
      _TileSpec(
        l10n.catDetailActivityLabel,
        cat.activityLevel != null
            ? catFormatActivityLevel(cat.activityLevel!, l10n)
            : notSet,
        iconAsset: 'Activity.svg',
      ),
      _TileSpec(
        l10n.catDetailBodyLabel,
        cat.weightCategory != null
            ? catFormatBodyCondition(cat.weightCategory!, l10n)
            : notSet,
        iconAsset: 'Body condition.svg',
      ),
      _TileSpec(
        l10n.catDetailStatusLabel,
        cat.neuteredStatus != null
            ? catFormatNeuteredStatus(cat.neuteredStatus!, l10n)
            : (cat.neutered ? l10n.catDetailStatusNeutered : l10n.neuteredIntact),
        iconAsset: 'Neuter status.svg',
      ),
    ];

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.catDetailDetailsSection, style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeS),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = DSDimens.sizeS;
              final tileWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: DSDimens.sizeS,
                children: tiles.map((t) {
                  return SizedBox(
                    width: tileWidth,
                    child: CatStatTile(
                      icon: t.icon,
                      iconAsset: t.iconAsset,
                      label: t.label,
                      value: t.value,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

            }

class _ConditionsCard extends StatelessWidget {
  final List<String> conditions;

  const _ConditionsCard({required this.conditions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.catDetailHealthConditionsSection, style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeS),
          Wrap(
            spacing: DSDimens.sizeXxs,
            runSpacing: DSDimens.sizeXxs,
            children: conditions
                .map((c) => _ConditionChip(condition: c))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String condition;

  const _ConditionChip({required this.condition});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E1),
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        catFormatHealthCondition(condition, l10n),
        style: DSTextStyles.label.copyWith(
          color: DSColors.accentDanger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  }

class _DeleteLink extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: DSColors.inkSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeXs,
          ),
        ),
        child: Text(
          l10n.catDetailDeleteProfile,
          style: DSTextStyles.bodyMd.copyWith(
            color: DSColors.inkSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

/// Personalized dietary tips derived from the cat's profile. Maps the
/// presentation [CatModel] to a [CatEntity] (field-identical) so it can reuse
/// the shared `recommendDiet` rule engine.
class _DietaryTipsCard extends StatelessWidget {
  final CatModel cat;

  const _DietaryTipsCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recommendations = recommendDiet(_entityFromModel(cat), l10n);
    if (recommendations.isEmpty) return const SizedBox.shrink();
    return DietaryRecommendationsCard(
      title: l10n.catDetailDietaryTipsSection,
      recommendations: recommendations,
    );
  }
}

/// Recommended catalog products ranked for this cat's profile.
class _RecommendedProductsCard extends StatelessWidget {
  final CatModel cat;

  const _RecommendedProductsCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return RecommendedProductsSection(cat: _entityFromModel(cat));
  }
}

/// Maps the presentation [CatModel] to a [CatEntity] (field-identical) for the
/// shared recommendation engines.
CatEntity _entityFromModel(CatModel m) => CatEntity(
      id: m.id,
      name: m.name,
      age: m.age,
      weight: m.weight,
      neutered: m.neutered,
      profileImageUrl: m.profileImageUrl,
      ageGroup: m.ageGroup,
      neuteredStatus: m.neuteredStatus,
      breed: m.breed,
      weightCategory: m.weightCategory,
      activityLevel: m.activityLevel,
      coatType: m.coatType,
      gender: m.gender,
      healthConditions: m.healthConditions,
    );

class _TileSpec {
  /// Colorful SVG asset under `assets/images/`, or null to fall back to [icon].
  final String? iconAsset;
  final IconData? icon;
  final String label;
  final String value;

  const _TileSpec(this.label, this.value, {this.iconAsset, this.icon});
}
