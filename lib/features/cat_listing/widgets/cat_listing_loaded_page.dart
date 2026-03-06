import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';

class CatListingLoadedWidget extends StatelessWidget {
  final List<CatModel> cats;
  final VoidCallback onPressed;
  const CatListingLoadedWidget({
    super.key,
    required this.cats,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: DSDimens.sizeS),
        itemCount: cats.length + 1, // +1 for the create cat button
        itemBuilder: (context, index) {
          if (index == cats.length) {
            // Create cat button at the bottom
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DSColors.primary,
                  foregroundColor: DSColors.white,
                  disabledBackgroundColor: DSColors.primaryDisabled,
                  disabledForegroundColor: DSColors.white,
                  padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeS),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                  ),
                ),
                child: const Text(
                  'Add a new cat profile!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }
          final cat = cats[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: DSDimens.sizeS),
            child: GestureDetector(
              onTap: () async {
                final deleted = await context.router.push<bool>(
                  CatDetailRoute(cat: cat),
                );
                // If a cat was deleted, refresh the list
                if (deleted == true && context.mounted) {
                  context.read<CatListingBloc>().add(
                    const CatListingFetchCatsEvent(),
                  );
                }
              },
              child: CatListItemCard(
                cat: cat,
                onScanPressed: () {
                  // TODO: Navigate to scan page for this cat
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class CatListItemCard extends StatelessWidget {
  final CatModel cat;
  final VoidCallback? onScanPressed;

  const CatListItemCard({super.key, required this.cat, this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeL,
        vertical: DSDimens.sizeL,
      ),
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: BorderRadius.circular(
          DSDimens.sizeM,
        ), // More rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Profile picture, name, and tags
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture
              Container(
                width: 90,
                height: 90,
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
                              size: 35,
                              color: DSColors.primary,
                            );
                          },
                        ),
                      )
                    : Icon(Icons.pets, size: 35, color: DSColors.primary),
              ),
              const SizedBox(width: DSDimens.sizeM),
              // Name and tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: DSDimens.sizeXxs),
                    Wrap(
                      spacing: DSDimens.sizeXxs,
                      runSpacing: DSDimens.sizeXxs,
                      children: [
                        if (cat.ageGroup != null)
                          _buildTag(
                            _formatAgeGroup(cat.ageGroup!),
                            DSColors.lightGrey,
                          ),
                        if (cat.breed != null)
                          _buildTag(cat.breed!, DSColors.lightGrey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeM),
          // Quick stats section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Quick stats',
              //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 16,
              //   ),
              // ),
              // const SizedBox(height: DSDimens.sizeS),
              // 2x2 grid of stat cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: "assets/images/Icons/Weight.png",
                      label: 'Weight',
                      value: cat.weight != null
                          ? '${cat.weight} kg'
                          : 'Not specified',
                    ),
                  ),
                  const SizedBox(width: DSDimens.sizeXxs),
                  Expanded(
                    child: _buildStatCard(
                      icon: "assets/images/Icons/gender.png",
                      label: 'Gender',
                      value: 'Not specified', // Gender not in model
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: "assets/images/icon-neutered.png",
                      label: 'Neutered',
                      value: cat.neutered || cat.neuteredStatus != null
                          ? (cat.neuteredStatus == 'neutered' ||
                                    cat.neuteredStatus == 'spayed' ||
                                    cat.neutered
                                ? 'Yes'
                                : 'No')
                          : 'No',
                    ),
                  ),
                  const SizedBox(width: DSDimens.sizeXxs),
                  Expanded(
                    child: _buildStatCard(
                      icon: "assets/images/icon-coat.png",
                      label: 'Coat',
                      value: cat.coatType != null
                          ? _formatCoatType(cat.coatType!)
                          : 'Not specified',
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Needs attention section
          Builder(
            builder: (context) {
              final children = <Widget>[
                if (cat.weightCategory != null &&
                    (cat.weightCategory == 'underweight' ||
                        cat.weightCategory == 'overweight' ||
                        cat.weightCategory == 'obese'))
                  _buildAttentionTag(
                    icon: Icons.warning,
                    text: 'Weight concern',
                    iconColor: Colors.red,
                  ),
                if (cat.healthConditions != null &&
                    cat.healthConditions!.isNotEmpty)
                  ...cat.healthConditions!.map((condition) {
                    if (condition.toLowerCase().contains('skin') ||
                        condition.toLowerCase().contains('allerg')) {
                      return _buildAttentionTag(
                        icon: Icons.pets,
                        text: 'Skin allergies',
                        iconColor: Colors.brown,
                      );
                    } else if (condition.toLowerCase().contains('pregnant')) {
                      return _buildAttentionTag(
                        icon: Icons.child_care,
                        text: 'Pregnant',
                        iconColor: Colors.orange,
                      );
                    }
                    return _buildAttentionTag(
                      icon: Icons.health_and_safety,
                      text: _formatSnakeCase(condition),
                      iconColor: Colors.orange,
                    );
                  }),
              ];

              if (children.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DSDimens.sizeXxs),
                  Text(
                    'Needs attention',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: DSDimens.sizeXxs),
                  Wrap(
                    spacing: DSDimens.sizeXxs,
                    runSpacing: DSDimens.sizeXxs,
                    children: children,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: DSColors.darkGrey),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeXxs),
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
        border: Border.all(color: DSColors.lightGrey),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 30, height: 30),
          const SizedBox(width: DSDimens.sizeXxxs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DSColors.black,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 12, color: DSColors.darkGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionTag({
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.lightGrey,
        borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? DSColors.darkGrey),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: DSColors.darkGrey)),
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

  String _formatCoatType(String coatType) {
    return switch (coatType.toLowerCase()) {
      'short' => 'Short hair',
      'medium' => 'Medium hair',
      'long' => 'Long hair',
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
