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
                      icon: "assets/images/Icons/cake.png",
                      label: 'Age',
                      value: cat.age != null
                          ? _formatAge(cat.age!)
                          : 'Not specified',
                    ),
                  ),
                  const SizedBox(width: DSDimens.sizeXxs),
                  Expanded(
                    child: _buildStatCard(
                      icon: "assets/images/Icons/gender.png",
                      label: 'Gender',
                      value: cat.gender != null
                          ? _formatGender(cat.gender!)
                          : 'Not specified',
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
                      icon: "assets/images/Icons/hair.png",
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
          // Health Conditions section
          if (cat.healthConditions != null &&
              cat.healthConditions!.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeXxs),
            Text(
              'Health Conditions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: DSDimens.sizeXxs),
            Wrap(
              spacing: DSDimens.sizeXxs,
              runSpacing: DSDimens.sizeXxs,
              children: cat.healthConditions!.map((condition) {
                return _buildConditionChip(condition);
              }).toList(),
            ),
          ],
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: DSColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(icon, width: 18, height: 18),
            ),
          ),
          const SizedBox(width: DSDimens.sizeXxs),
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

  Widget _buildConditionChip(String condition) {
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

  String _formatAgeGroup(String ageGroup) {
    return switch (ageGroup.toLowerCase()) {
      'kitten' => 'Kitten',
      'adult' => 'Adult',
      'senior' => 'Senior',
      _ => ageGroup,
    };
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
      _ => gender,
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
