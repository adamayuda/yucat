import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_detail/presentation/bloc/cat_detail_bloc.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';

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
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CatDetailNavigateToEditState) {
          context.router.push(CreateCatRoute(cat: state.cat));
        }
      },
      builder: (context, state) {
        if (state is CatDetailLoadingState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cat Profile')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final cat =
            state is CatDetailLoadedState ? state.cat : widget.cat;

        return Scaffold(
          backgroundColor: DSColors.surface,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(cat),
                _buildStatsRow(cat),
                _buildProfileCompletion(cat),
                _buildDetailsGrid(cat),
                if (cat.healthConditions != null &&
                    cat.healthConditions!.isNotEmpty)
                  _buildHealthConditions(cat),
                _buildDeleteText(cat),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(CatModel cat) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DSColors.primarySurface, DSColors.surface],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSDimens.sizeM,
                vertical: DSDimens.sizeXxs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.chevron_left,
                      color: DSColors.black,
                      size: 24,
                    ),
                  ),
                  const Text(
                    'Cat Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DSColors.black,
                    ),
                  ),
                  _buildIconButton(
                    onTap: () => _bloc.add(CatDetailEditEvent(cat: cat)),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: DSColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSDimens.sizeL),
            // Avatar
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DSColors.primaryMuted, Color(0xFFF5E8FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26ED67CA),
                    blurRadius: 32,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DSColors.white,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: cat.profileImageUrl != null
                      ? Image.network(
                          cat.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Image.asset(
                                'assets/images/Icons/face cat.png',
                                width: 64,
                                height: 64,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Image.asset(
                            'assets/images/Icons/face cat.png',
                            width: 64,
                            height: 64,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: DSDimens.sizeS),
            // Name & breed
            Text(
              cat.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: DSColors.darkBlue,
              ),
            ),
            const SizedBox(height: DSDimens.sizeXxxs),
            Text(
              cat.breed ?? 'Unknown breed',
              style: const TextStyle(
                fontSize: 14,
                color: DSColors.darkGrey,
              ),
            ),
            const SizedBox(height: DSDimens.sizeXl),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DSColors.white,
          borderRadius: BorderRadius.circular(DSDimens.sizeXs),
          border: Border.all(color: DSColors.border),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildStatsRow(CatModel cat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeM, 0, DSDimens.sizeM, DSDimens.sizeM,
      ),
      child: Row(
        children: [
          if (cat.age != null)
            Expanded(
              child: _buildStatCard(
                'assets/images/Icons/cake.png',
                _formatAge(cat.age!),
                'Age',
              ),
            ),
          if (cat.age != null) const SizedBox(width: 10),
          if (cat.activityLevel != null)
            Expanded(
              child: _buildStatCard(
                'assets/images/Icons/fire.png',
                _formatActivityLevel(cat.activityLevel!),
                'Activity',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String iconPath, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: BorderRadius.circular(DSDimens.sizeS),
        border: Border.all(color: DSColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DSColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(iconPath, width: 20, height: 20),
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DSColors.darkBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: DSColors.darkGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletion(CatModel cat) {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeM, 0, DSDimens.sizeM, DSDimens.sizeM,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSDimens.sizeS),
        decoration: BoxDecoration(
          color: DSColors.white,
          borderRadius: BorderRadius.circular(DSDimens.sizeS),
          border: Border.all(color: DSColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Completion',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: DSColors.bodyText,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DSColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8,
                backgroundColor: DSColors.primarySurface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  DSColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(CatModel cat) {
    const notSet = 'Not set';
    final tiles = <_TileData>[
      _TileData('assets/images/Icons/breed.png', 'Breed', cat.breed ?? notSet),
      _TileData(
        'assets/images/Icons/cake.png',
        'Age',
        cat.age != null ? _formatAge(cat.age!) : notSet,
      ),
      _TileData(
        'assets/images/Icons/gender.png',
        'Gender',
        cat.gender != null ? _formatGender(cat.gender!) : notSet,
      ),
      _TileData(
        'assets/images/Icons/hair.png',
        'Coat Type',
        cat.coatType != null ? _formatCoatType(cat.coatType!) : notSet,
      ),
      _TileData(
        'assets/images/Icons/syringe.png',
        'Status',
        cat.neuteredStatus != null
            ? _formatNeuteredStatus(cat.neuteredStatus!)
            : (cat.neutered ? 'Neutered' : 'Intact'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeM, 0, DSDimens.sizeM, DSDimens.sizeS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DSColors.darkBlue,
            ),
          ),
          const SizedBox(height: DSDimens.sizeXs),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: tiles.map((tile) {
                  return SizedBox(
                    width: tileWidth,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DSColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: DSColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: DSColors.primarySurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Image.asset(
                                tile.iconPath,
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tile.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: DSColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tile.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: DSColors.darkBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHealthConditions(CatModel cat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeM, DSDimens.sizeXxs, DSDimens.sizeM, DSDimens.sizeS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Conditions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DSColors.darkBlue,
            ),
          ),
          const SizedBox(height: DSDimens.sizeXs),
          Wrap(
            spacing: DSDimens.sizeXxs,
            runSpacing: DSDimens.sizeXxs,
            children: cat.healthConditions!.map((condition) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: DSColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DSColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _healthConditionIcon(condition),
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatSnakeCase(condition),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DSColors.bodyText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteText(CatModel cat) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeL),
        child: GestureDetector(
          onTap: () async {
            final confirmed = await _showDeleteConfirmationDialog(
              context,
              cat.name,
            );
            if (confirmed == true && cat.id != null) {
              _bloc.add(CatDetailDeleteEvent(catId: cat.id!));
            }
          },
          child: const Text(
            'Delete profile',
            style: TextStyle(
              fontSize: 13,
              color: DSColors.darkGrey,
              decoration: TextDecoration.underline,
              decorationColor: DSColors.darkGrey,
            ),
          ),
        ),
      ),
    );
  }

  String _healthConditionIcon(String condition) {
    final key = condition.toLowerCase();
    if (key.contains('urinary') || key.contains('urine')) {
      return 'assets/images/Icons/urine.png';
    } else if (key.contains('allerg') || key.contains('wheat') ||
        key.contains('grain')) {
      return 'assets/images/Icons/wheat.png';
    } else if (key.contains('kidney') || key.contains('renal')) {
      return 'assets/images/Icons/water.png';
    } else if (key.contains('diabetes') || key.contains('sugar')) {
      return 'assets/images/Icons/sugar.png';
    } else if (key.contains('digest') || key.contains('stomach') ||
        key.contains('food')) {
      return 'assets/images/Icons/food.png';
    } else if (key.contains('weight') || key.contains('obes')) {
      return 'assets/images/Icons/Weight.png';
    } else {
      return 'assets/images/Icons/heart.png';
    }
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
      'high' => 'High',
      _ => _formatSnakeCase(level),
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
      'short' => 'Short Hair',
      'medium' => 'Medium Hair',
      'long' => 'Long Hair',
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

class _TileData {
  final String iconPath;
  final String label;
  final String value;
  const _TileData(this.iconPath, this.label, this.value);
}
