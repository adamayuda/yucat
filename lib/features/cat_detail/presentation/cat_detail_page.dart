import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/presentation/utils/cat_diet_recommendations.dart';
import 'package:yucat/features/cat/presentation/widgets/dietary_recommendations_card.dart';
import 'package:yucat/features/cat/presentation/widgets/recommended_products_section.dart';
import 'package:yucat/features/cat_detail/presentation/bloc/cat_detail_bloc.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_detail_skeleton.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_hero_section.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_stat_tile.dart';
import 'package:yucat/features/cat_listing/mappers/cat_model_to_entity.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_entry_analytics.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/due_item_card.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_confirm_dialog.dart';
import 'package:yucat/presentation/components/ds_tag_chip.dart';
import 'package:yucat/presentation/components/photo_source_sheet.dart';

@RoutePage()
class CatDetailPage extends StatefulWidget {
  final CatModel cat;

  const CatDetailPage({super.key, required this.cat});

  @override
  State<CatDetailPage> createState() => _CatDetailPageState();
}

class _CatDetailPageState extends State<CatDetailPage> {
  late CatDetailBloc _bloc;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatDetailBloc>();
    _bloc.add(CatDetailInitialEvent(cat: widget.cat));
  }

  Future<void> _changePhoto(CatModel cat) async {
    final file = await pickPhotoFromSheet(context, _imagePicker);
    if (file == null || !mounted) return;
    _bloc.add(CatDetailPhotoChangedEvent(cat: cat, photo: file));
  }

  /// Awaits the wizard so the page can re-read the cat it comes back to —
  /// otherwise an edited photo or breed stays stale until the user backs out.
  Future<void> _openEdit(CatModel cat) async {
    await context.router.push(CreateCatRoute(cat: cat));
    if (!mounted || cat.id == null) return;
    _bloc.add(CatDetailReloadEvent(catId: cat.id!));
  }

  /// The carnet row. Logs the shared "carnet door" event with this surface,
  /// then reloads the cat on return: the carnet may have changed the profile
  /// weight, and the reload re-derives the health row from the (cached) mirror.
  Future<void> _openCarnet(CatModel cat, CatHealthSummary? health) async {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.homeHealthCardTapped,
      properties: healthEntryTapProperties(
        surface: HealthEntrySurface.catDetail,
        state: healthEntryStateOf(health),
        cat: catEntityFromModel(cat),
        item: health?.nearest,
      ),
    );
    await context.router.push(HealthCarnetRoute(cat: cat));
    if (!mounted) return;
    // A weigh-in in the carnet updates the profile weight, so re-read the cat
    // (which re-derives the health row too) rather than only the row.
    if (cat.id != null) {
      _bloc.add(CatDetailReloadEvent(catId: cat.id!));
    } else {
      _bloc.add(const CatDetailHealthRefreshEvent());
    }
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
        } else if (state is CatDetailPhotoErrorState) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.catDetailPhotoUpdateError),
              backgroundColor: DSColors.accentDanger,
            ),
          );
        } else if (state is CatDetailNavigateToEditState) {
          _openEdit(state.cat);
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
        final isUploadingPhoto =
            state is CatDetailLoadedState && state.isUploadingPhoto;
        final health = state is CatDetailLoadedState ? state.health : null;

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
                      CatHeroSection(
                        cat: cat,
                        onPhotoTap: cat.id == null
                            ? null
                            : () => _changePhoto(cat),
                        isUploadingPhoto: isUploadingPhoto,
                      ),
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
                      _HealthCarnetCard(
                        health: health,
                        onTap: () => _openCarnet(cat, health),
                      ),
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
        cat.breed == null ? notSet : catFormatBreed(cat.breed!, l10n),
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
                .map((c) => DSTagChip(
                      label: catFormatHealthCondition(c, l10n),
                    ))
                .toList(),
          ),
        ],
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

/// Entry point to the cat's health record — vaccines, visits, treatments and
/// weight over time.
///
/// Live since the carnet's visibility work: the row carries the nearest due
/// item with its urgency pill, the record count and the last weight, read
/// through the shared `resolveCatHealth` (cache-backed, so a return from the
/// carnet costs nothing). Three fallbacks, in order of honesty:
///
/// - [health] is null (the read failed, or has not landed yet) → the original
///   static subtitle. Never the setup invite: a failed read on a full carnet
///   must not tell the owner to start over.
/// - No history → the setup invite.
/// - History but nothing due inside the horizon → "All up to date".
class _HealthCarnetCard extends StatelessWidget {
  final CatHealthSummary? health;
  final VoidCallback onTap;

  const _HealthCarnetCard({required this.health, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final health = this.health;
    final nearest = health?.nearest;

    final String line1;
    if (health == null) {
      line1 = l10n.healthCarnetEntryEmpty;
    } else if (!health.hasHistory) {
      line1 = l10n.catDetailHealthSetup;
    } else if (nearest != null) {
      line1 = '${healthProtocolName(nearest.protocol.id, l10n)} · '
          '${healthUrgencyLabel(nearest, l10n)}';
    } else {
      line1 = l10n.catDetailHealthAllClear;
    }

    String? line2;
    if (health != null && health.hasHistory) {
      final parts = [l10n.catDetailHealthRecords(health.recordCount)];
      final kg = health.latestWeightKg;
      if (kg != null) {
        parts.add(l10n.catDetailHealthLastWeight(healthFormatKg(kg, locale)));
      }
      line2 = parts.join(' · ');
    }

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DSColors.tintCoralSoft,
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              size: 22,
              color: DSColors.accentDanger,
            ),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: DSDimens.sizeXxs,
                  runSpacing: DSDimens.sizeXxxs,
                  children: [
                    Text(l10n.healthCarnetTitle, style: DSTextStyles.titleMd),
                    if (nearest != null) HealthUrgencyPill(item: nearest),
                  ],
                ),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  line1,
                  style: DSTextStyles.bodyMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (line2 != null) ...[
                  const SizedBox(height: DSDimens.sizeXxxs),
                  Text(
                    line2,
                    style: DSTextStyles.caption.copyWith(
                      color: DSColors.inkTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: DSColors.inkTertiary,
          ),
        ],
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
    final recommendations = recommendDiet(catEntityFromModel(cat), l10n);
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
    return RecommendedProductsSection(cat: catEntityFromModel(cat));
  }
}

class _TileSpec {
  /// Colorful SVG asset under `assets/images/`, or null to fall back to [icon].
  final String? iconAsset;
  final IconData? icon;
  final String label;
  final String value;

  const _TileSpec(this.label, this.value, {this.iconAsset, this.icon});
}
