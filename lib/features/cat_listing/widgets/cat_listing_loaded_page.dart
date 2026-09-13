import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/cat_listing/widgets/add_cat_card.dart';
import 'package:yucat/features/cat_listing/widgets/cat_summary_card.dart';

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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        bottomInset + DSDimens.size5xl + DSDimens.sizeL,
      ),
      itemCount: cats.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: DSDimens.sizeXs),
      itemBuilder: (context, index) {
        if (index == cats.length) {
          return AddCatCard(onTap: onPressed);
        }
        final cat = cats[index];
        return CatSummaryCard(
          cat: cat,
          onTap: () async {
            await context.router.push<bool>(CatDetailRoute(cat: cat));
            // Detail can delete the cat, change its photo in place, or hand
            // off to the edit wizard — refetch unconditionally rather than
            // thread a "changed" flag through every one of those exits.
            if (context.mounted) {
              context.read<CatListingBloc>().add(
                const CatListingFetchCatsEvent(),
              );
            }
          },
        );
      },
    );
  }
}
