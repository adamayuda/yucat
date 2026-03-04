import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          // Navigate back after successful deletion
          Navigator.of(context).pop(true);
        } else if (state is CatDetailErrorState) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CatDetailNavigateToEditState) {
          // TODO: Navigate to edit screen in Phase 5
        }
      },
      builder: (context, state) {
        if (state is CatDetailLoadingState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cat Profile'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final cat = state is CatDetailLoadedState
            ? state.cat
            : widget.cat;

        return Scaffold(
          backgroundColor: DSColors.white,
          appBar: AppBar(
            backgroundColor: DSColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: DSColors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(
                color: DSColors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: DSColors.primary),
                onPressed: () {
                  _bloc.add(CatDetailEditEvent(cat: cat));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(DSDimens.sizeM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo Section
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DSColors.lightGrey,
                    ),
                    child: cat.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              cat.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.pets,
                                  size: 60,
                                  color: DSColors.primary,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.pets,
                            size: 60,
                            color: DSColors.primary,
                          ),
                  ),
                ),
                const SizedBox(height: DSDimens.sizeM),

                // Basic Info Section
                _buildSectionTitle(context, 'Basic Information'),
                const SizedBox(height: DSDimens.sizeS),
                _buildInfoCard(context, [
                  if (cat.breed != null)
                    _buildInfoRow(Icons.pets, 'Breed', cat.breed!),
                  if (cat.ageGroup != null)
                    _buildInfoRow(
                      Icons.cake,
                      'Age Group',
                      _formatAgeGroup(cat.ageGroup!),
                    ),
                  if (cat.age != null)
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Age',
                      '${cat.age} ${cat.age == 1 ? 'year' : 'years'}',
                    ),
                  if (cat.weight != null)
                    _buildInfoRow(
                      Icons.monitor_weight,
                      'Weight',
                      '${cat.weight} kg',
                    ),
                  if (cat.weightCategory != null)
                    _buildInfoRow(
                      Icons.scale,
                      'Weight Category',
                      _formatWeightCategory(cat.weightCategory!),
                    ),
                  if (cat.activityLevel != null)
                    _buildInfoRow(
                      Icons.directions_run,
                      'Activity Level',
                      _formatActivityLevel(cat.activityLevel!),
                    ),
                ]),
                const SizedBox(height: DSDimens.sizeM),

                // Status Section
                _buildSectionTitle(context, 'Status'),
                const SizedBox(height: DSDimens.sizeS),
                _buildInfoCard(context, [
                  _buildInfoRow(
                    Icons.medical_services,
                    'Neutered',
                    cat.neuteredStatus != null
                        ? _formatNeuteredStatus(cat.neuteredStatus!)
                        : (cat.neutered ? 'Yes' : 'No'),
                  ),
                  if (cat.coatType != null)
                    _buildInfoRow(
                      Icons.brush,
                      'Coat Type',
                      _formatCoatType(cat.coatType!),
                    ),
                ]),

                // Health Conditions Section
                if (cat.healthConditions != null &&
                    cat.healthConditions!.isNotEmpty) ...[
                  const SizedBox(height: DSDimens.sizeM),
                  _buildSectionTitle(context, 'Health Conditions'),
                  const SizedBox(height: DSDimens.sizeS),
                  _buildInfoCard(
                    context,
                    cat.healthConditions!
                        .map((condition) => _buildInfoRow(
                              Icons.health_and_safety,
                              '',
                              _formatSnakeCase(condition),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: DSDimens.sizeXl),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirmed = await _showDeleteConfirmationDialog(
                        context,
                        cat.name,
                      );
                      if (confirmed == true && cat.id != null) {
                        _bloc.add(CatDetailDeleteEvent(catId: cat.id!));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding:
                          const EdgeInsets.symmetric(vertical: DSDimens.sizeS),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                      ),
                    ),
                    child: const Text(
                      'Delete Profile',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: DSDimens.sizeM),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeM),
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: BorderRadius.circular(DSDimens.sizeS),
        border: Border.all(color: DSColors.lightGrey),
      ),
      child: Column(
        children: children
            .expand((widget) => [widget, const SizedBox(height: DSDimens.sizeS)])
            .toList()
          ..removeLast(), // Remove last spacing
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DSColors.primary),
        const SizedBox(width: DSDimens.sizeS),
        if (label.isNotEmpty) ...[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DSColors.darkGrey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: DSColors.black,
              ),
            ),
          ),
        ] else
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: DSColors.black,
              ),
            ),
          ),
      ],
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatAgeGroup(String ageGroup) {
    return switch (ageGroup.toLowerCase()) {
      'kitten' => 'Kitten',
      'adult' => 'Adult',
      'senior' => 'Senior',
      _ => ageGroup,
    };
  }

  String _formatWeightCategory(String category) {
    return switch (category.toLowerCase()) {
      'underweight' => 'Underweight',
      'normal' => 'Normal',
      'overweight' => 'Overweight',
      'obese' => 'Obese',
      _ => _formatSnakeCase(category),
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
