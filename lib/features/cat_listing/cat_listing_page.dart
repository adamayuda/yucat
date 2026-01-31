import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_empty_page.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_error_page.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_loading_page.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_loaded_page.dart';
import 'package:yucat/features/paywall/widgets/paywall_error_widget.dart';
import 'package:yucat/presentation/top_app_bar/top_app_bar.dart';
import 'package:yucat/features/paywall/paywall_page.dart';

@RoutePage()
class CatListingPage extends StatefulWidget {
  const CatListingPage({super.key});

  @override
  State<CatListingPage> createState() => _CatListingPageState();
}

class _CatListingPageState extends State<CatListingPage> {
  late CatListingBloc _bloc;

  void _navigateToProfile() {
    context.router.push(const ProfileRoute());
  }

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatListingBloc>();
    _bloc.add(const CatListingInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatListingBloc, CatListingState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => Scaffold(
        backgroundColor: DSColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TopAppBar(
            title: 'My Cats',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            rightButton: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToProfile,
            ),
          ),
        ),
        body: _onStateChangeBuilder(state),
      ),
    );
  }

  Widget _onStateChangeBuilder(CatListingState state) {
    switch (state) {
      case CatListingLoadingState():
        return CatListingLoadingWidget();
      case CatListingLoadedState():
        return CatListingLoadedWidget(cats: state.cats);
      case CatListingErrorState():
        return CatListingErrorWidget(
          message: state.message,
          onPressed: () => _bloc.add(const CatListingFetchCatsEvent()),
        );
      case CatListingShowPaywallState():
        return CatListingLoadingWidget();
      case CatListingEmptyState():
        return CatListingEmptyWidget(
          onPressed: () =>
              _bloc.add(CatListingCreateCatEvent(context: context)),
        );
      default:
        return const SizedBox();
    }
  }

  // Widget _buildScaffold(CatListingState state) {
  //   return Scaffold(
  //     backgroundColor: DSColors.white,
  //     appBar: PreferredSize(
  //       preferredSize: const Size.fromHeight(kToolbarHeight),
  //       child: TopAppBar(
  //         title: 'My Cats',
  //         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         rightButton: IconButton(
  //           icon: const Icon(Icons.settings),
  //           onPressed: _navigateToProfile,
  //         ),
  //       ),
  //     ),
  //     body: _buildBody(state),
  //   );
  // }

  // Widget _buildBody(CatListingState state) {
  //   switch (state) {
  //     case CatListingLoadingState():
  //       return const Center(child: CircularProgressIndicator());
  //     case CatListingLoadedState():
  //       if (state.cats.isEmpty) {
  //         return _buildEmptyState();
  //       }
  //       return _buildCatList(state.cats);
  //     case CatListingErrorState():
  //       return CatListingErrorWidget(
  //         message: state.message,
  //         onPressed: () => _bloc.add(const CatListingFetchCatsEvent()),
  //       );
  //     case CatListingShowPaywallState():
  //       // Paywall is shown via listener, keep showing loading while paywall is displayed
  //       return const Center(child: CircularProgressIndicator());
  //   }
  // }

  // Widget _buildCatList(List<CatModel> cats) {
  //   return ListView.builder(
  //     padding: EdgeInsets.all(DSDimens.sizeS),
  //     itemCount: cats.length + 1, // +1 for the add cat tile
  //     itemBuilder: (context, index) {
  //       if (index == cats.length) {
  //         // Add cat tile at the bottom
  //         return Padding(
  //           padding: EdgeInsets.only(bottom: DSDimens.sizeS),
  //           child: _buildAddCatTile(),
  //         );
  //       }
  //       final cat = cats[index];
  //       return Padding(
  //         padding: EdgeInsets.only(bottom: DSDimens.sizeS),
  //         child: _buildCatCard(cat),
  //       );
  //     },
  //   );
  // }

  // Widget _buildAddCatTile() {
  //   return InkWell(
  //     onTap: () => _bloc.add(CatListingCreateCatEvent(context: context)),
  //     borderRadius: BorderRadius.circular(DSDimens.sizeS),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: DSColors.white,
  //         border: Border.all(color: DSColors.lightGrey),
  //         borderRadius: BorderRadius.circular(DSDimens.sizeS),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.all(DSDimens.sizeM),
  //         child: Row(
  //           children: [
  //             Container(
  //               width: 70,
  //               height: 70,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 color: DSColors.primary.withOpacity(0.1),
  //               ),
  //               child: Icon(Icons.add, size: 35, color: DSColors.primary),
  //             ),
  //             SizedBox(width: DSDimens.sizeM),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'New Cat Profile',
  //                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                       fontWeight: FontWeight.bold,
  //                       color: DSColors.primary,
  //                     ),
  //                   ),
  //                   SizedBox(height: DSDimens.sizeXxs),
  //                   Text(
  //                     'Add a new cat to your profile',
  //                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                       color: DSColors.darkGrey,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCatCard(CatModel cat) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: DSColors.white,
  //       border: Border.all(color: DSColors.lightGrey),
  //       borderRadius: BorderRadius.circular(DSDimens.sizeS),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.all(DSDimens.sizeM),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Profile image
  //           Container(
  //             width: 70,
  //             height: 70,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: DSColors.primary.withOpacity(0.1),
  //             ),
  //             child: cat.profileImageUrl != null
  //                 ? ClipOval(
  //                     child: Image.network(
  //                       cat.profileImageUrl!,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (context, error, stackTrace) {
  //                         return Icon(
  //                           Icons.pets,
  //                           size: 35,
  //                           color: DSColors.primary,
  //                         );
  //                       },
  //                     ),
  //                   )
  //                 : Icon(Icons.pets, size: 35, color: DSColors.primary),
  //           ),
  //           SizedBox(width: DSDimens.sizeM),
  //           // Cat information
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Name
  //                 Text(
  //                   cat.name,
  //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 SizedBox(height: DSDimens.sizeS),
  //                 // Primary info - always shown
  //                 _buildInfoRow(Icons.cake, _getAgeInfo(cat)),
  //                 SizedBox(height: DSDimens.sizeXxs),
  //                 _buildInfoRow(Icons.pets, _getBreedInfo(cat)),
  //                 SizedBox(height: DSDimens.sizeXxs),
  //                 _buildInfoRow(Icons.scale, _getWeightInfo(cat)),
  //                 SizedBox(height: DSDimens.sizeXxs),
  //                 _buildInfoRow(Icons.medical_services, _getNeuteredInfo(cat)),
  //                 // Secondary info
  //                 if (cat.coatType != null) ...[
  //                   SizedBox(height: DSDimens.sizeXxs),
  //                   _buildInfoRow(Icons.brush, _formatCoatType(cat.coatType!)),
  //                 ],
  //                 if (cat.activityLevel != null) ...[
  //                   SizedBox(height: DSDimens.sizeXxs),
  //                   _buildInfoRow(
  //                     Icons.directions_run,
  //                     _formatActivityLevel(cat.activityLevel!),
  //                   ),
  //                 ],
  //                 if (cat.weightCategory != null) ...[
  //                   SizedBox(height: DSDimens.sizeXxs),
  //                   _buildInfoRow(
  //                     Icons.monitor_weight,
  //                     _formatWeightCategory(cat.weightCategory!),
  //                   ),
  //                 ],
  //                 if (cat.healthConditions != null &&
  //                     cat.healthConditions!.isNotEmpty) ...[
  //                   SizedBox(height: DSDimens.sizeXxs),
  //                   _buildInfoRow(
  //                     Icons.health_and_safety,
  //                     'Health: ${cat.healthConditions!.map((c) => _formatSnakeCase(c)).join(', ')}',
  //                   ),
  //                 ],
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfoRow(IconData icon, String text) {
  //   return Row(
  //     children: [
  //       Icon(icon, size: 16, color: DSColors.darkGrey),
  //       SizedBox(width: DSDimens.sizeXxs),
  //       Expanded(
  //         child: Text(
  //           text,
  //           style: Theme.of(
  //             context,
  //           ).textTheme.bodyMedium?.copyWith(color: DSColors.darkGrey),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // String _getAgeInfo(CatModel cat) {
  //   if (cat.ageGroup != null) {
  //     final label = switch (cat.ageGroup) {
  //       'kitten' => 'Kitten',
  //       'adult' => 'Adult',
  //       'senior' => 'Senior',
  //       _ => cat.ageGroup!,
  //     };
  //     if (cat.age != null) {
  //       return '$label (${cat.age} ${cat.age == 1 ? 'year' : 'years'} old)';
  //     }
  //     return label;
  //   } else if (cat.age != null) {
  //     return '${cat.age} ${cat.age == 1 ? 'year' : 'years'} old';
  //   }
  //   return 'Age: Not specified';
  // }

  // String _getBreedInfo(CatModel cat) {
  //   return cat.breed != null ? 'Breed: ${cat.breed}' : 'Breed: Not specified';
  // }

  // String _getWeightInfo(CatModel cat) {
  //   if (cat.weight != null) {
  //     return 'Weight: ${cat.weight} kg';
  //   }
  //   return 'Weight: Not specified';
  // }

  // String _getNeuteredInfo(CatModel cat) {
  //   if (cat.neuteredStatus != null) {
  //     return 'Status: ${_formatNeuteredStatus(cat.neuteredStatus!)}';
  //   } else if (cat.neutered) {
  //     return 'Status: Neutered';
  //   }
  //   return 'Status: Not specified';
  // }

  // String _formatNeuteredStatus(String status) {
  //   return switch (status) {
  //     'neutered' => 'Neutered',
  //     'spayed' => 'Spayed',
  //     'intact' => 'Intact',
  //     _ => status,
  //   };
  // }

  // String _formatCoatType(String coatType) {
  //   return switch (coatType) {
  //     'short' => 'Short coat',
  //     'medium' => 'Medium coat',
  //     'long' => 'Long coat',
  //     'hairless' => 'Hairless',
  //     _ => _formatSnakeCase(coatType),
  //   };
  // }

  // String _formatActivityLevel(String level) {
  //   return switch (level) {
  //     'low' => 'Low activity',
  //     'moderate' => 'Moderate activity',
  //     'high' => 'High activity',
  //     _ => _formatSnakeCase(level),
  //   };
  // }

  // String _formatWeightCategory(String category) {
  //   return switch (category) {
  //     'underweight' => 'Underweight',
  //     'normal' => 'Normal weight',
  //     'overweight' => 'Overweight',
  //     'obese' => 'Obese',
  //     _ => _formatSnakeCase(category),
  //   };
  // }

  // String _formatSnakeCase(String text) {
  //   return text
  //       .split('_')
  //       .map(
  //         (word) => word.isEmpty
  //             ? ''
  //             : word[0].toUpperCase() + word.substring(1).toLowerCase(),
  //       )
  //       .join(' ');
  // }
}
