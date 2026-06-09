import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_detail/presentation/bloc/cat_detail_bloc.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_hero_section.dart';
import 'package:yucat/features/cat_detail/presentation/widgets/cat_stat_tile.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
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
            backgroundColor: DSColors.tintLavender,
            body: AppLoadingWidget(),
          );
        }

        final cat = state is CatDetailLoadedState ? state.cat : widget.cat;

        return Scaffold(
          backgroundColor: DSColors.tintLavender,
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
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $catName?'),
        content: const Text(
          'Are you sure you want to delete this cat profile? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: DSColors.accentDanger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final CatModel cat;

  const _ProfileCompletionCard({required this.cat});

  @override
  Widget build(BuildContext context) {
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
                'Profile completion',
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
    const notSet = 'Not set';
    final tiles = <_TileSpec>[
      _TileSpec(Icons.pets_rounded, 'Breed', cat.breed ?? notSet),
      _TileSpec(
        Icons.cake_rounded,
        'Age',
        cat.age != null ? _formatAge(cat.age!) : notSet,
      ),
      _TileSpec(
        cat.gender?.toLowerCase() == 'male'
            ? Icons.male_rounded
            : cat.gender?.toLowerCase() == 'female'
                ? Icons.female_rounded
                : Icons.transgender_rounded,
        'Gender',
        cat.gender != null ? _formatGender(cat.gender!) : notSet,
      ),
      _TileSpec(
        Icons.brush_rounded,
        'Coat',
        cat.coatType != null ? _formatCoatType(cat.coatType!) : notSet,
      ),
      _TileSpec(
        Icons.directions_run_rounded,
        'Activity',
        cat.activityLevel != null
            ? _formatActivityLevel(cat.activityLevel!)
            : notSet,
      ),
      _TileSpec(
        Icons.monitor_weight_rounded,
        'Body',
        cat.weightCategory != null
            ? _formatBodyCondition(cat.weightCategory!)
            : notSet,
      ),
      _TileSpec(
        Icons.medical_services_rounded,
        'Status',
        cat.neuteredStatus != null
            ? _formatNeuteredStatus(cat.neuteredStatus!)
            : (cat.neutered ? 'Neutered' : 'Intact'),
      ),
    ];

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: DSTextStyles.titleMd),
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

  String _formatAge(int ageInMonths) {
    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;
    if (years == 0) return '$months mo';
    if (months == 0) return '$years ${years == 1 ? 'yr' : 'yrs'}';
    return '$years ${years == 1 ? 'yr' : 'yrs'} $months mo';
  }

  String _formatGender(String gender) {
    return switch (gender.toLowerCase()) {
      'male' => 'Male',
      'female' => 'Female',
      _ => _formatSnakeCase(gender),
    };
  }

  String _formatActivityLevel(String level) {
    return switch (level.toLowerCase()) {
      'low' => 'Low',
      'moderate' => 'Moderate',
      'medium' => 'Medium',
      'high' => 'High',
      _ => _formatSnakeCase(level),
    };
  }

  String _formatBodyCondition(String category) {
    return switch (category.toLowerCase()) {
      'underweight' => 'Underweight',
      'normal' => 'Ideal weight',
      'overweight' => 'Overweight',
      'obese' => 'Obese',
      _ => _formatSnakeCase(category),
    };
  }

  String _formatNeuteredStatus(String status) {
    return switch (status.toLowerCase()) {
      'neutered' => 'Neutered',
      'spayed' => 'Spayed',
      'intact' => 'Intact',
      'pregnant' => 'Pregnant',
      'lactating' => 'Lactating',
      _ => _formatSnakeCase(status),
    };
  }

  String _formatCoatType(String coatType) {
    return switch (coatType.toLowerCase()) {
      'short' => 'Short hair',
      'short_hair' => 'Short hair',
      'medium' => 'Medium hair',
      'long' => 'Long hair',
      'long_hair' => 'Long hair',
      'hairless' => 'Hairless',
      _ => _formatSnakeCase(coatType),
    };
  }

  String _formatSnakeCase(String text) {
    return text
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

class _ConditionsCard extends StatelessWidget {
  final List<String> conditions;

  const _ConditionsCard({required this.conditions});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health conditions', style: DSTextStyles.titleMd),
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
        _formatSnakeCase(condition),
        style: DSTextStyles.label.copyWith(
          color: DSColors.accentDanger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatSnakeCase(String text) {
    return text
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

class _DeleteLink extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          'Delete profile',
          style: DSTextStyles.bodyMd.copyWith(
            color: DSColors.inkSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _TileSpec {
  final IconData icon;
  final String label;
  final String value;

  const _TileSpec(this.icon, this.label, this.value);
}
